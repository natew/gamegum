class GamesController < ApplicationController
  before_filter :check_url, :only => [:show, :edit, :destroy, :update]
  before_filter :check_owner, :only => [:edit, :update]
  before_filter :get_categories, :except => [:show, :rate]
  before_filter :get_latest_and_content, :only => [:viewed, :index, :rated, :favorites, :discussed, :category, :featured, :live]

  caches_action :index,     :cache_path => Proc.new { |c| c.params }, :layout => false
  caches_action :category,  :cache_path => Proc.new { |c| c.params }, :layout => false
  caches_action :viewed,    :cache_path => Proc.new { |c| c.params }, :layout => false
  caches_action :rated,     :cache_path => Proc.new { |c| c.params }, :layout => false
  caches_action :discussed, :cache_path => Proc.new { |c| c.params }, :layout => false
  caches_action :favorites, :cache_path => Proc.new { |c| c.params }, :layout => false
  caches_action :adult, :cache_path => Proc.new { |c| c.params }, :layout => false
  caches_action :teen, :cache_path => Proc.new { |c| c.params }, :layout => false
  caches_action :everyone, :cache_path => Proc.new { |c| c.params }, :layout => false
  caches_action :featured,  :layout => false

  def index
    title = 'Browse Games'

    per_page = 8
    sort = get_sort_conditions(params[:sort])

    conditions = case params[:sort]
            when "rating" then "rating_count > 4"
            when "rating_reverse" then "rating_count > 4"
            end

    if params[:sort] and !@content_filter.empty?
      conditions = conditions + ' and ' + @content_filter
    else
      conditions = @content_filter
    end

    @games = Game.paginate :conditions => conditions, :order => sort, :include => [:user], :page => params[:page], :per_page => per_page
  end

  def show
	  # Comments
    @comments = @game.comments.paginate(
                      :order => 'comments.created_at DESC',
                      :page => params[:page],
                      :per_page => 8)

  	# Render comments list on ajax request
    #if request.xml_http_request?
    #  render :partial => 'comment_area'
    #else
	    # Width / Height
	    @width  = [@game.width,650].min
	    @height = @width == 650 ? ((650.fdiv(@game.width))*@game.height).round : @game.height

	    # Restricted
	    @game_restricted = true if @game.adult and !user_logged_in_and_of_age?

	    # Content Rating
	    if @game.adult
	      @rated = 'adult'
	    elsif @game.violence or @game.language
	      @rated = 'mature'
	    else
	      @rated = 'all'
	    end

	    # Tags
	    @tags = @game.tags

	    # Related games
	    @related = []
	    words    = @game.title.match(/^(\w+)/)
	    if words
	      words         = words.to_a
	      results       = 0
	      searching     = true
	      num_words     = [words.length, 4].min
	      already_found = [@game.id]

	      while searching
	        query          = words.first(num_words).join(' ')
	        filter         = "id NOT IN (#{already_found.join(', ')})"
	        found          = Game.search_by_title(query).where(filter).limit(8)
	        results       += found.size
	        searching      = false if (results >= 8 or num_words <= 1)
	        already_found += found.collect { |x| x.id }
	        already_found.flatten!
	        num_words     -= 1
	        @related      += found
	      end
	    end

	    not_in         = " and id NOT IN (#{already_found.join(', ')})" unless already_found.nil?
	    related_filter = "category_id = #{@game.category_id} #{not_in}"
	    @related      += Game.where(related_filter).order('views DESC').limit(8) if @related.size < 8
	    @related       = @related[0,8]
	  #end

	  #render :action => 'show'
	  update_views_and_pulse
  end

  def new
    title = 'Submit a Game'
    @can_submit = !(logged_in? && current_user.email_confirmed)

    @game = Game.new
  end

  def create
    if request.post? and params[:game]
      @game = Game.new(params[:game])
      @game.user = current_user

      if @game.save and logged_in?
        redirect_to @game
        flash[:notice] = "You game has been submitted, it may take a few moments to process!"
      else
        render :action => 'new'
        flash[:notice] = "Error submitting game!"
      end
    end
  end

  def update
    if @game.update_attributes(params[:game])
      redirect_to @game, :notice => 'Successfully edited!'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @game = Game.find(params[:id])
    @game.destroy
    flash[:notice] = 'Game deleted!'
    redirect_to '/account/games'
  end

  def tags
    @tags = Game.tag_counts_on(:tags, :limit => 50)
  end

  def tag
    @tag = params[:tag]
    @title = 'Games tagged with ' + @tag
    @games = Game.tagged_with(@tag)
    @top_tags = Game.tag_counts_on(:tags, :limit => 12)
  end

  def live
    @title = 'Now Playing'
    list_games_by 'Now Playing', { :conditions => @content_filter, :order => 'updated_at DESC' }
    render 'games/list'
  end

  def featured
    title = 'Featured'
    @games    = Game.where('featured = true', :include => [:user]).order('updated_at desc')
  end

  def pages
    title = 'Games by Topic'
    @pages    = Page.order('updated_at desc')
  end

  def viewed
    list_games_by 'Most Viewed', { :conditions => @content_filter, :order => 'views DESC' }
  end

  def rated
    case params[:within].to_i
      when 365
        min = 10
      when 31
        min = 7
      when 7
        min = 0
      else
        min = 20
    end

    list_games_by 'Highest Rated', { :conditions => "games.rating_count > #{min}", :order => 'rating_avg DESC' }
  end

  def favorites
    set_title('Most Favorited')
    cols   = Game.column_names.collect {|c| "games.#{c}"}.join(",")
    where  = " WHERE games.created_at > '#{params[:within].to_i.days.ago.to_s(:db)}'" unless params[:within].nil?

    @games = Game.find_by_sql "SELECT games.*, count(favorites.id) as favorites_count FROM games INNER JOIN favorites on favorites.game_id = games.id#{where} GROUP BY favorites.game_id, #{cols} ORDER BY favorites_count DESC LIMIT 21"
    render :template => '/games/list'
  end

  def discussed
    set_title('Most Discussed')
    cols   = Game.column_names.collect {|c| "games.#{c}"}.join(",")
    where  = " WHERE games.created_at > '#{params[:within].to_i.days.ago.to_s(:db)}'" unless params[:within].nil?
    @games = Game.find_by_sql "SELECT games.*, comments.game_id, count(comments.id) as comments_count FROM games INNER JOIN comments on comments.game_id = games.id#{where} GROUP BY comments.game_id, #{cols} ORDER BY comments_count DESC LIMIT 21"
    render :template => '/games/list'
  end

  def rate
    if !logged_in?
      render :text => 'Log in first!'
    else
      @game = Game.find(params[:game].to_i)
      @game.rate(params[:rating].to_i, current_user)
      Pulse.create({:category => 'rating', :user => current_user, :game => @game, :stars => params[:rating].to_i})

      if request.xml_http_request?
        render :partial => 'rate_submitted'
      else
        respond_to do |format|
          format.html do
            flash[:notice] = 'Rating submitted successfully'
            redirect_to @game
          end
        end
      end
    end
  end

  def category
    @category = Category.find_by_title(params[:category].titlecase)
    @games = Game.paginate :order => 'views DESC', :conditions => { :category_id => @category.id }.merge(@content_filter), :page => params[:page], :per_page => 21
  end

  private

  def update_views_and_pulse
    # Update attributes
    @game.update_attribute(:views, @game.views.next) # +1 views

    # Played pulse if logged in
    if logged_in?
      users_last_pulse = Pulse.where("user_id = #{current_user.id} and game_id = #{@game.id} and created_at > '#{1.day.ago.to_s(:db)}'").limit(1)

      Pulse.create({
        :category => 'play',
        :user => current_user,
        :game => @game,
        :adult => @game.nudity
      }) if users_last_pulse.empty?
    end
  end

  def check_url
  	id, slug = params[:id].split('%2F')
    @game = Game.find(id, :include => [:user])

    #redirect_to url_for(@game) if slug != @game.slug
  end

  def check_owner
    redirect_to @game unless logged_in? and (current_user.id == @game.user_id or current_user.permissions > 2)
  end

  def set_title(page)
    unless page == 'Now Playing'
      @title = "#{page}"
    end
  end

  def get_categories
    @categories = Category.order('title')
    @top_tags = Game.tag_counts_on(:tags, :limit => 12)
  end

  def get_latest_and_content
    @recent = Game.order("created_at DESC").limit(4)
    @content_filter = {}
    @content_filter[:violence] = true if params[:violence] == 'on'
    @content_filter[:language] = true if params[:language] == 'on'
    @content_filter[:nudity]   = (true || user_logged_in_and_of_age?) if params[:nudity] == 'on'
  end

  def list_games_by(page, options = {})
    set_title(page)
    @games = Game.find_within(params[:within].to_i, options.merge({ :page => params[:page], :per_page => 18 }))
    render 'games/list' unless page == 'Now Playing'
  end
end
