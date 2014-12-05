# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

require 'fastercsv'
require 'fileutils'
require Rails.root + 'vendor/activerecord-import/base.rb'

def elapsed(table)
  # Skip if @only is set
  return if !@only.nil? and @only != table
  
  puts "Begin import on #{table}"
  @num       = 0
  start_time = Time.now
  
  yield
  
  # Update sequence after import
  ActiveRecord::Base.connection.execute("select setval('#{table}_id_seq', (select max(id) + 1 from #{table}));")
  
  puts "#{Time.now-start_time} seconds elapsed.  Imported #{@num} records on #{table}.\n\n"
end

def empty_data
  puts "Emptying current public media directories"
  ['flash', 'icons', 'avatars'].each do |dir|
    FileUtils.remove_dir("#{Rails.root}/public/#{dir}")
    FileUtils.mkdir("#{Rails.root}/public/#{dir}")
  end
end

def clean!(string)
  string.gsub!(/([^\x20-\x7E]|\s{2,}|\n)/, '') unless string.nil?
  string.strip! unless string.nil?
end

def export_legacy_tables
  games_tables = ['games', 'comments', 'gamerate', 'favorites', 'news', 'forum_threads', 'forum_posts', 'forum_topics']
  users_tables = ['users', 'friends', 'private_messages']
  
  # Connect to games database
  ActiveRecord::Base.establish_connection(
    :adapter => 'mysql',
    :database => 'legacy'
  )
  games_tables.each { |table| export_table(table) }
  
  # Connect to users database
  ActiveRecord::Base.establish_connection(
    :adapter => 'mysql',
    :database => 'legacy_users'
  )
  users_tables.each { |table| export_table(table) }

  # Re-establish our old connection
  ActiveRecord::Base.establish_connection 'development'
end

def export_table(name)
  puts "Dumping legacy table #{name.titlecase}..."
  
  # Remove old csv
  outfile = "#{Rails.root}/lib/previous_data/#{name}.csv"
  FileUtils.remove(outfile) if File.exists?(outfile)
  
  # Loop through old records and transform to csv
  csv = []
  records = ActiveRecord::Base.connection.execute("SELECT * FROM #{name}")
  FasterCSV.open(outfile, 'w', { :force_quotes => true, :row_sep => "\r\n" }) do |csv|
    records.each do |row|
      case name
        when 'games'
          clean! row[1]
          clean! row[11]
        when 'users'
          clean! row[1]
          clean! row[19]
          clean! row[21]
          clean! row[22]
          clean! row[23]
          clean! row[24]
          clean! row[25]
        when 'comments'
          clean! row[4]
          clean! row[6]
        when 'forum_posts'
          clean! row[2]
          clean! row[4]
          clean! row[5]
          clean! row[7]
        when 'friends'
          clean! row[3]
        when 'forum_topics'
          clean! row[1]
          clean! row[3]
        when 'forum_threads'
          clean! row[2]
          clean! row[3]
          clean! row[4]
          clean! row[6]
        when 'friends'
          clean! row[3]
        when 'private_messages'
          clean! row[2]
          clean! row[4]
          clean! row[6]
          clean! row[7]
      end
      csv << row
    end
  end
  
  puts "Dumped"
end

# Bitwise functions
def get_bits(bits)
  result = [0, 0, 0, 0, 0]
  
  5.times do |i|
    result[i] = i if (2**(i-1)).to_i & bits > 0
  end
  
  return result
end

# Options
# RESET=false will NOT delete old media directories
# DUMP=true will dump the legacy database into csv files
# COPY=false will prevent copying over media files
# ONLY={table} will only seed given table
empty_data unless ENV["RESET"] == 'false'
export_legacy_tables if ENV["DUMP"] == 'true'
@copy_data = (ENV["COPY"] == 'true') ? true : false
@only = ENV["ONLY"]

elapsed('categories') {
	columns	= [:id, :title]
	values	= [
		[1, 'Action'],
		[2, 'Arcade'],
		[4, 'Casino'],
		[5, 'Other'],
		[6, 'Platform'],
		[7, 'Puzzle'],
		[8, 'Sport'],
		[9, 'Strategy'],
		[10, 'Auto'],
		[11, 'Adventure'],
		[13, 'Sim'],
		[14, 'Shooter'],
	]
	
	Category.import(columns, values)
	@num = values.size
}

elapsed('games') {
  columns = [:id, :title, :screenshot, :views, :rating_count, :rating_total, :rating_avg, :active, :description, :user_id, :category_id, :featured, :created_at, :updated_at, :featured_at, :flash_file_name, :width, :height, :icon_file_name, :nudity, :violence, :language]
  pulse_columns = [:category, :description, :user_id, :game_id, :created_at]
  values = []
  pulse_values = []
  n = 1
  
  FasterCSV.foreach("#{Rails.root}/lib/previous_data/games.csv", :row_sep => "\r\n") do |row|
    # Get old information
    id, title, category, user, userid, filename, systemfile, icon, width, height, shortdescription, description, content, rates_num, rates_sum, rating, views, awards, flag, featured, active, published, changed, issues, screenshot, date_featured, beta_version = row
    
    # Check if we actually have a swf file
    if File.extname(systemfile) == '.swf'
      transfer = true
      
      # Flash file
      flash_filename = "#{id}_original.swf"
      
      if @copy_data
        begin
          FileUtils.cp(	"#{Rails.root}/lib/previous_files/games/#{systemfile}",
        				"#{Rails.root}/public/flash/#{flash_filename}" )
        rescue
          puts " -- ERROR: copying flash file to /public/flash"
          transfer = false
        end
      end

      if transfer
        if @copy_data
          # Icon file
          icon_ext = File.extname(icon)
          if icon_ext =~ /^.(jpg|gif|png)/
            icon_filename = "#{id}_original#{icon_ext}"
            begin
              FileUtils.cp(	"#{Rails.root}/lib/previous_files/icons/#{icon}",
        					"#{Rails.root}/public/icons/#{id}_original#{icon_ext}" )
            rescue Exception => e
              #puts " -- WARNING: icon missing #{e.message}"
              icon_filename = nil
            end
          else
            #puts " -- WARNING: wrong icon filetype #{icon_ext}"
            icon_filename = nil
          end
        end

		cr = get_bits(content.to_i)
		nudity = cr[1] == 1 ? true : false
		violence = (cr[2] == 2 or cr[3] == 3) ? true : false
		language = cr[4] == 4 ? true : false
        created_at = Time.at(published.to_i)
        updated_at = Time.at(changed.to_i)
        featured_at = Time.at(date_featured.to_i)
        featured = featured == "1" ? true : false
        rating = sprintf("%.2f", (rates_sum.to_i.div(rates_num.to_i))) if rates_num.to_i > 0
        title.strip!
  
        values << [id, title, screenshot, views, rates_num, rates_sum, rating, active, description, userid, category, featured, created_at, updated_at, featured_at, flash_filename, width, height, icon_filename, nudity, violence, language]
        pulse_values << ['game', description[0..200], userid, id, created_at]
      
        if n%200 == 0
          Game.import columns, values, :validate => false, :timestamps => false
          values = []
          GC.start
        end
  
        n = n.next
        @num = @num.next
      end
    else
      puts " -- ERROR: Filename not .swf (#{title})"
    end
  end
          
  Pulse.import pulse_columns, pulse_values, :timestamps => false
  Game.import(columns, values, :validate => false, :timestamps => false) unless values.empty?
}


elapsed('users') {
  columns = [:id, :login, :crypted_password, :salt, :email, :email_confirmed, :location, :age, :aim, :msn, :about_me, :gumpoints, :active, :show_avatar, :show_email, :revenue_share, :views, :adsense, :website, :created_at, :updated_at, :avatar_file_name, :signature, :ip, :banned]
  values = []
  n = 1

  FasterCSV.foreach("#{Rails.root}/lib/previous_data/users.csv") do |row|
    id, username, password, rand, email, code, emailconfirmed, permissions, comments, submissions, favorites, avatar, showavatar, newsletter, commentnotify, joined, visited, gamequality, age, website, gumpoints, location, aboutme, signature, aim, msn, showemail, posts, profile_views, showcode, ip, banned, friends, t_submissions, t_favorites, t_comments, t_posts, threads, adsense_id, revenuesharing, referred_by, adsense_channel, alternatestyle, image, showimage, pulse_comments, pulse_ratings, pulse_posts = row
    email = "reset_email_please_#{n}@example.com" unless email.match /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    email = "proph3t#{n}@gmail.com" if email == 'proph3t@gmail.com'
    confirmed = emailconfirmed == "1" ? true : false
    showavatar = showavatar == "0" ? false : true
    showemail = showemail == "0" ? false : true
    banned = banned == "1" ? true : false
    revenue_share = revenuesharing == "1" ? true : false
    aim = '' if aim == '0'
    age = Time.parse("12/#{Time.now.year - age.to_i}")

    # Avatar file
    if @copy_data
      avatar_ext = File.extname(avatar)
      if avatar_ext =~ /^.(jpg|gif|png)/
        avatar_filename = "#{id}_original#{avatar_ext}"
        begin
          FileUtils.cp(	"#{Rails.root}/lib/previous_files/avatars/#{avatar}",
    					"#{Rails.root}/public/avatars/#{id}_original#{avatar_ext}" )
        rescue Exception => e
          puts " -- WARNING: avatar file missing #{e.message}"
          avatar_filename = nil
        end
      else
        avatar_filename = nil
      end
    end

    values << [id, username.strip, password, rand, email, confirmed, location, age, aim, msn, aboutme, gumpoints, true, showavatar, showemail, revenue_share, profile_views, adsense_id, website, Time.at(joined.to_i), Time.at(visited.to_i), avatar_filename, signature, ip, banned]

    if n%500 == 0
      User.import columns, values, :validate => false, :timestamps => false
      values = []
      GC.start
    end

    n = n.next
    @num = @num.next
  end

  User.import(columns, values, :validate => false, :timestamps => false) unless values.empty?
  # Make proph3t admin
  User.find_by_login('proph3t').update_attribute(:permissions, 3)
}


elapsed('comments') {
  columns = [:id, :message, :game_id, :user_id, :created_at]
  values = []
  pulse_columns = [:category, :description, :user_id, :game_id, :created_at]
  pulse_values = []
  n = 1

  FasterCSV.foreach("#{Rails.root}/lib/previous_data/comments.csv") do |row|
    # Get old information
    id, parent, active, user, title, date, comment, type = row
    created_at = Time.at(date.to_i)
    updated_at = Time.now

    values << [id, comment, parent, user, created_at] if type == "0"
    pulse_values << ['comment', comment[0..200], user, parent, created_at] if type == "0"

    if n%500 == 0
      Comment.import columns, values, :timestamps => false
      values = []
      GC.start
    end

    n = n.next
    @num = @num.next
  end

  Pulse.import pulse_columns, pulse_values, :timestamps => false
  Comment.import(columns, values, :timestamps => false) unless values.empty?
}
    

elapsed('ratings') {
  columns = [:rater_id, :rated_id, :rated_type, :rating]
   values = []

   FasterCSV.foreach("#{Rails.root}/lib/previous_data/gamerate.csv") do |row|
     # Get old information
     id, game, user, rating, date = row

     values << [user, game, 'Game', rating]
     @num = @num.next
   end

   Rating.import(columns, values)
}


elapsed('favorites') {  
  columns = [:user_id, :game_id]
  values = []

  FasterCSV.foreach("#{Rails.root}/lib/previous_data/favorites.csv") do |row|
    # Get old information
    id, user, game = row

    values << [user, game]
    @num = @num.next
  end

  Favorite.import(columns, values)
}

elapsed('articles') {  
  columns = [:id, :title, :body, :live, :user_id, :created_at]
  values = []

  FasterCSV.foreach("#{Rails.root}/lib/previous_data/news.csv") do |row|
    # Get old information
    id, active, title, author, authorid, message, published = row

    values << [id, title, message, (active == "1" ? true : false), authorid, Time.at(published.to_i)]
    @num = @num.next
  end

  Article.import(columns, values, :timestamps => false)
}

elapsed('discussions') {
  columns = [:id, :topic_id, :user_id, :title, :message, :views, :locked, :sticky, :created_at, :updated_at]
  values = []

  FasterCSV.foreach("#{Rails.root}/lib/previous_data/forum_threads.csv") do |row|
    # Get old information
    id, topic, topic_title, title, user, userid, message, views, active, date, last_updated = row

    values << [id, topic, userid, title, message, views, false, (active == "2" ? true : false), Time.at(date.to_i), Time.at(last_updated.to_i)]
    @num = @num.next
  end

  Discussion.import(columns, values, :validate => false, :timestamps => false)
}

elapsed('messages') {
  columns = [:id, :receiver_deleted, :receiver_purged, :sender_deleted, :sender_purged, :read_at, :receiver_id, :sender_id, :subject, :body, :created_at, :updated_at]
  values = []
  n = 1

  @time = Time.now
  FasterCSV.foreach("#{Rails.root}/lib/previous_data/private_messages.csv") do |row|
    # Get old information
    id, from_id, from_user, to_id, to_user, status, title, message, date = row

    if status == "1"
      read = false
    elsif status == "2" or status == "0"
      read = true
    end

    values << [id, (status == "0" ? true : nil), nil, nil, nil, (read ? @time : nil), to_id, from_id, title, message, Time.at(date.to_i), nil]

    if n%1000 == 0
      Message.import(columns, values, :validate => false, :timestamps => false)
      values = []
      GC.start
    end

    n = n.next
    @num = @num.next
  end

  Message.import(columns, values, :validate => false, :timestamps => false) unless values.empty?
}

elapsed('posts') {
  columns = [:id, :discussion_id, :user_id, :message, :active, :created_at, :updated_at]
  values = []

  FasterCSV.foreach("#{Rails.root}/lib/previous_data/forum_posts.csv") do |row|
    # Get old information
    id, topic, topic_title, thread, thread_title, user, userid, message, active, date = row

    values << [id, thread, userid, message, active, Time.at(date.to_i), nil]
    @num = @num.next
  end

  Post.import(columns, values, :validate => false, :timestamps => false)
}

elapsed('topics') {
  columns = [:id, :title, :icon, :description]
  values = []

  FasterCSV.foreach("#{Rails.root}/lib/previous_data/forum_topics.csv") do |row|
    # Get old information
    id, title, icon, description = row

    values << [id, title, icon, description]
    @num = @num.next
  end

  Topic.import(columns, values)
}

elapsed('friendships') {
  columns = [:user_id, :friend_id, :created_at, :accepted_at]
  values = []
  users = []
  
  FasterCSV.foreach("#{Rails.root}/lib/previous_data/friends.csv") do |row|
    # Get old information
    id, user, friend, friend_username, date = row
    
    # If needed, set accepted_at rather than adding a new row
    users << user # Add each user
    if users.include? friend # If the friend is already a user, we have an accepted friendship
      index = users.index friend # Get the index in the users array of the match we found
      ActiveRecord::Base.connection.execute("UPDATE friendships SET accepted_at = '#{Time.at(date.to_i).strftime('%Y-%m-%d %H:%M:%S')}' WHERE user_id = #{index} AND friend_id = #{user}")
    else
      values << [user, friend, Time.at(date.to_i), nil]
      @num = @num.next
    end
  end
  
  Friendship.import(columns, values, :timestamps => false)
}