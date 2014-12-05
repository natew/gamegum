namespace :legacy do
  tables = [
  		'legacy:migrate:categories',
  		'legacy:migrate:games',
  		'legacy:migrate:users',
  		'legacy:migrate:comments',
  		'legacy:migrate:ratings',
  		'legacy:migrate:favorites',
  		'legacy:migrate:articles',
  		'legacy:migrate:discussions',
  		'legacy:migrate:messages',
  		'legacy:migrate:posts',
  		'legacy:migrate:topics',
  		'legacy:migrate:friendships'
  		]
  
  task :migrate => tables do
    puts "Migrated all tables.\n\n"
  end
  
  namespace :migrate do
    task :reset do
      Rake::Task['db:reset'].invoke
      puts "\n\n"
      Rake::Task['legacy:migrate'].invoke
    end
  
    task :setup => :environment do
      @num = 0
      @reset = true if (ENV["RESET"] == 'true' or ENV["R"] == 't')
      @db ||= (ENV["DB"] || 'development')

      if  @sql.nil?
        ActiveRecord::Base.establish_connection @db
        @sql = ActiveRecord::Base.connection

		    require 'fastercsv'
        require File.dirname(__FILE__) + '/activerecord-import/base.rb'
      end
    end
    
    task :categories => :setup do
      @table = 'category'
      if @reset
        reset_migration(2)
      end
      
      if Category.count(:all) > 0
        empty_table
      else
        Category.create(:title => 'Action')
        Category.create(:title => 'Arcade')
        Category.create(:title => 'Casino')
        Category.create(:title => 'Other')
        Category.create(:id => 7, :title => 'Platform')
        Category.create(:title => 'Puzzle')
        Category.create(:title => 'Sport')
        Category.create(:title => 'Strategy')
        Category.create(:title => 'Auto')
        Category.create(:title => 'Adventure')
        Category.create(:title => 'Sim')
        Category.create(:title => 'Shooter')
      end
    end
    
    task :games => :setup do
      @table = 'game'
      if @reset
        reset_migration(1)
        reset_migration(17)
        reset_migration(19)
        reset_dir('flash')
        reset_dir('icons')
        export_legacy('games')
      end
      
      if Game.count(:all) > 0
        empty_table
      else
        elapsed {
          alter_id
          
          columns = [:id, :title, :screenshot, :views, :content_rating, :rating_count, :rating_total, :rating_avg, :active, :description, :user_id, :category_id, :featured, :created_at, :updated_at]
          pulse_columns = [:category, :description, :user_id, :game_id, :created_at]
          values = []
          pulse_values = []
          n = 1

          FasterCSV.foreach("#{Rails.root}/lib/previous_data/games.csv") do |row|
            # Get old information
            id, title, category, user, userid, filename, systemfile, icon, width, height, shortdescription, description, content, rates_num, rates_sum, rating, views, awards, flag, featured, active, published, changed, issues, screenshot, date_featured, beta_version = row

            created_at = Time.at(published.to_i)
            updated_at = Time.at(changed.to_i)
            featured = featured == "1" ? true : false
            rating = sprintf("%.2f", (rates_sum.to_i/rates_num.to_i)) if rates_num.to_i > 0
            title.strip!
          
            values << [id, title, screenshot, views, content, rates_num, rates_sum, rating, active, description, userid, category, featured, created_at, updated_at]
            pulse_values << ['game', description, userid, id, created_at]
          
            if n%500 == 0
              Game.import columns, values, :validate => false, :timestamps => false
              values = []
              GC.start
            end
          
            # Import Icon
            path_to = "#{Rails.root}/lib/previous_files/icons/#{icon}"
            if File.exists?(path_to) and !icon.empty?              
              begin
                Icon.create :game_id => id, :temp_path => path_to, :filename => icon
              rescue
                puts "error saving icon #{path_to}"
              end
            end
          
            # Import Flash
            path_to = "#{Rails.root}/lib/previous_files/games/#{systemfile}"
            if File.exists?(path_to) and !systemfile.empty?
              Flash.create :game_id => id, :temp_path => path_to, :filename => systemfile
            end
          
            n = n.next
            @num = @num.next
          end
          
          Pulse.import pulse_columns, pulse_values, :timestamps => false
          Game.import(columns, values, :validate => false, :timestamps => false) unless values.empty?
          
          unalter_id
        }
      end
    end
    
    task :users => :setup do
      @table = 'user'
      if @reset
        reset_migration(3)
        reset_migration(18)
        reset_dir('avatars')
        export_legacy('users', 'legacy_users')
      end
      
      if User.count(:all) > 0
        empty_table
      else
        elapsed {
          alter_id
      
          columns = [:id, :login, :crypted_password, :salt, :email, :email_confirmed, :location, :aim, :msn, :about_me, :gumpoints, :active, :show_avatar, :show_email, :revenue_share, :views, :adsense, :website, :created_at, :updated_at]
          values = []
          n = 1
    
          FasterCSV.foreach("#{Rails.root}/lib/previous_data/users.csv") do |row|
            id, username, password, rand, email, code, emailconfirmed, permissions, comments, submissions, favorites, avatar, showavatar, newsletter, commentnotify, joined, visited, gamequality, age, website, gumpoints, location, aboutme, signature, aim, msn, showemail, posts, profile_views, showcode, ip, banned, friends, t_submissions, t_favorites, t_comments, t_posts, threads, adsense_id, revenuesharing, referred_by, adsense_channel, alternatestyle, image, showimage, pulse_comments, pulse_ratings, pulse_posts = row
            email = "resetemail#{n}@example.com" unless email.match /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
            email = "proph3t#{n}@gmail.com" if email == 'proph3t@gmail.com'
            confirmed = emailconfirmed == "1" ? true : false
            showavatar = showavatar == "1" ? true : false
            showemail = showemail == "1" ? true : false
            revenue_share = revenuesharing == "1" ? true : false
            aim = '' if aim == '0'

            values << [id, username.strip, password, rand, email, confirmed, location, aim, msn, aboutme, gumpoints, true, showavatar, showemail, revenue_share, profile_views, adsense_id, website, Time.at(joined.to_i), Time.at(visited.to_i)]
    
            if n%500 == 0
              User.import columns, values, :validate => false, :timestamps => false
              values = []
              GC.start
            end
            
            # Import Avatar
            path_to = "#{Rails.root}/lib/previous_files/avatars/#{avatar}"
            if File.exists?(path_to) and !avatar.nil?
              file = ActionController::TestUploadedFile.new(path_to, File.mime_type?(path_to))
              
              begin
                Avatar.create :user_id => id, :uploaded_data => file, :filename => avatar
              rescue
                puts "error: could not upload avatar #{path_to}"
              end
                
              file.close
            end

            n = n.next
            @num = @num.next
          end
    
          User.import(columns, values, :validate => false, :timestamps => false) unless values.empty?
      
          unalter_id
        }
      end
    end
    
    task :comments => :setup do
      @table = 'comment'
      if @reset
        reset_migration(6)
        export_legacy('comments')
      end
      
      if Comment.count(:all) > 0
        empty_table
      else
        elapsed {
          alter_id
      
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
            pulse_values << ['comment', comment, user, parent, created_at] if type == "0"
    
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
      
          unalter_id
        }
      end
    end
    
    task :ratings => :setup do
      @table = 'rating'
      if @reset
        export_legacy('gamerate')
      end
      
      if Rating.count(:all) > 0
        empty_table
      else
        elapsed {
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
      end
    end
    
    task :favorites => :setup do
      @table = 'favorite'
      if @reset
        reset_migration(12)
        export_legacy('favorites')
      end
      
      if Favorite.count(:all) > 0
        empty_table
      else
        elapsed {
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
      end
    end
    
    task :articles => :setup do
      @table = 'article'
      if @reset
        reset_migration(8)
        export_legacy('news')
      end
      
      if Article.count(:all) > 0
        empty_table
      else
        elapsed {
          alter_id
      
          columns = [:id, :title, :body, :live, :user_id, :created_at]
          values = []
    
          FasterCSV.foreach("#{Rails.root}/lib/previous_data/news.csv") do |row|
            # Get old information
            id, active, title, author, authorid, message, published = row
    
            values << [id, title, message, (active == "1" ? true : false), authorid, Time.at(published.to_i)]
            @num = @num.next
          end
    
          Article.import(columns, values, :timestamps => false)
      
          unalter_id
        }
      end
    end
    
    task :discussions => :setup do
      @table = 'discussion'
      if @reset
        reset_migration(16)
        export_legacy('forum_threads')
      end
      
      if Discussion.count(:all) > 0
        empty_table
      else
        elapsed {
          alter_id
      
          columns = [:id, :topic_id, :user_id, :title, :message, :views, :locked, :sticky, :created_at, :updated_at]
          values = []
    
          FasterCSV.foreach("#{Rails.root}/lib/previous_data/forum_threads.csv") do |row|
            # Get old information
            id, topic, topic_title, title, user, userid, message, views, active, date, last_updated = row
    
            values << [id, topic, userid, title, message, views, false, (active == "2" ? true : false), Time.at(date.to_i), Time.at(last_updated.to_i)]
            @num = @num.next
          end
    
          Discussion.import(columns, values, :timestamps => false)
      
          unalter_id
        }
      end
    end
    
    task :messages => :setup do
      @table = 'message'
      if @reset
        reset_migration(20080602092241)
        export_legacy('private_messages', 'legacy_users')
      end
      
      if Message.count(:all) > 0
        empty_table
      else
        elapsed {
          columns = [:id, :receiver_deleted, :receiver_purged, :sender_deleted, :sender_purged, :read_at, :receiver_id, :sender_id, :subject, :body, :created_at, :updated_at]
          values = []
          n = 1
    
          FasterCSV.foreach("#{Rails.root}/lib/previous_data/private_messages.csv") do |row|
            # Get old information
            id, from_id, from_user, to_id, to_user, status, title, message, date = row
    
            if status == "1"
              read = false
            elsif status == "2"
              read = true
            end
    
            values << [id, (status == "0" ? true : nil), nil, nil, nil, (read ? Time.now : nil), to_id, from_id, title, message, Time.at(date.to_i), nil]
    
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
      end
    end
    
    task :posts => :setup do
      @table = 'post'
      if @reset
        reset_migration(15)
        export_legacy('forum_posts')
      end
      
      if Post.count(:all) > 0
        empty_table
      else
        elapsed {
          alter_id
      
          columns = [:id, :discussion_id, :user_id, :message, :active, :created_at, :updated_at]
          values = []
    
          FasterCSV.foreach("#{Rails.root}/lib/previous_data/forum_posts.csv") do |row|
            # Get old information
            id, topic, topic_title, thread, thread_title, user, userid, message, active, date = row
    
            values << [id, thread, userid, message, active, Time.at(date.to_i), nil]
            @num = @num.next
          end
    
          Post.import(columns, values, :timestamps => false)
      
          unalter_id
        }
      end
    end
    
    task :topics => :setup do
      @table = 'topic'
      if @reset
        reset_migration(14)
        export_legacy('forum_topics')
      end
      
      if Topic.count(:all) > 0
        empty_table
      else
        elapsed {
          alter_id
      
          columns = [:id, :title, :icon, :description]
          values = []
    
          FasterCSV.foreach("#{Rails.root}/lib/previous_data/forum_topics.csv") do |row|
            # Get old information
            id, title, icon, description = row
    
            values << [id, title, icon, description]
            @num = @num.next
          end
    
          Topic.import(columns, values)
      
          unalter_id
        }
      end
    end
    
    task :friendships => :setup do
      @table = 'friendship'
      if @reset
        reset_migration(20080601232750)
        export_legacy('friends', 'legacy_users')
      end
      
      if Friendship.count(:all) > 0
        empty_table
      else
        elapsed {
        
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
              @sql.execute("UPDATE `friendships` SET `accepted_at` = '#{Time.at(date.to_i).strftime('%Y-%m-%d %H:%M:%S')}' WHERE 'user_id' = #{index} AND 'friend_id' = #{user}")
            else
              values << [user, friend, Time.at(date.to_i), nil]
              @num = @num.next
            end
          end
          
          Friendship.import(columns, values, :timestamps => false)
        }
      end
    end
  end
  
  def export_legacy(name)
    puts "Dumping legacy table #{name.titlecase}"
    
    # Remove old csv
    outfile = "#{Rails.root}/lib/previous_data/#{name}.csv"
    FileUtils.remove(outfile) if File.exists?(outfile)
    
    # Connect to old database
    ActiveRecord::Base.establish_connection(
      :adapter => 'mysql',
      :database => 'legacy'
    )
    
    # Loop through old records and transform to csv
    records = ActiveRecord::Base.connection.execute("SELECT * FROM #{name}")
    FasterCSV.open(outfile, 'a', { :force_quotes => true, :row_sep => "\r\n" }) do |csv|
      records.each do |row|
        csv << row
      end
    end
     
    puts "Dumped legacy table #{name.titlecase}"
    
    # Re-establish our old connection
    ActiveRecord::Base.establish_connection @db
    @sql = ActiveRecord::Base.connection
  end
  
  def reset_migration(id)
    [:down, :up].each { |d| ActiveRecord::Migrator.run(d, "db/migrate/", id) }
  end
  
  def reset_dir(name)
    FileUtils.remove_dir("#{Rails.root}/public/#{name}")
    FileUtils.mkdir("#{Rails.root}/public/#{name}")
  end
  
  def alter_id
    @sql.execute("ALTER TABLE `#{@table.plural}` CHANGE `id` `id` int(8)")
  end
  
  def unalter_id
    @sql.execute("ALTER TABLE `#{@table.plural}` CHANGE `id` `id` int(8) unsigned auto_increment")
  end
  
  def empty_table
    puts "#{@table.plural.titlecase} table not empty, skipping.\n\n"
  end
  
  def elapsed
    @num = 0
    puts "Importing " + @table.plural.titlecase
    start_time = Time.now
    yield
    puts "#{Time.now-start_time} seconds elapsed.  Imported #{@num} records.\n\n"
  end
end