class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  cache_sweeper :article_sweeper, :only => [:create]
  cache_sweeper :game_sweeper,    :only => [:create, :update]

  before_filter :redirect_from_www, :meta_defaults, :set_previous_location, :lights_cookie
  
  # 404 for NotFound
  #rescue_from Exception, :with => :not_found unless Rails.env == 'development'
  
  # Returns the days ago given a created_at
  def days_ago(created_at)
  	( (Time.now - created_at.to_time) / 60 / 60 / 24 ).round
  end
  
  # Adult content functions
  def user_logged_in_and_of_age?
    logged_in? and current_user.of_age?
  end
  
  def show_adult_content?
    user_logged_in_and_of_age?
  end
  
  # Post a users message to a channel
  def say
    return false unless request.xhr?
    @user = current_user
    @chat = Chat.create({ :sender_id => current_user.id, :receiver_id => params[:receiver] })  
    
    # Get the message
    message = params[:message]
    return false unless message
    
    if message.match(/^\/\w+/)
      # It's an IRC style command
      command, arguments = message.scan(/^\/(\w+)(.+?)$/).flatten
      logger.info(command)
      case command
        when 'me'
          @user.action_in_channel(@channel, arguments)
          @message = InstantMessage.find(:first, :order => "id DESC", :conditions => ["sender_id = ?", @user.id])
        when 'nick'
          #session[:nickname] = arguments
        when 'join'
          @aux_command = %(window.location = "channel/visit/#{arguments}";)
        else
          return false
      end
    else
      @user.say_in_chat(@chat, message)
      @message = InstantMessage.find(:first, :order => "id DESC", :conditions => ["user_id = ?", @user.id])
    end
    
    render :layout => false
  end
  
  def not_found
    @featured_games = Game.where("featured = true").order("random()").limit(12)
    render 'shared/404', :status => 404
  end
  
  
  # Sanitize strings for sql
  def sanitize_for_sql(string)
  	#string.gsub(/\\/, '\&\&').gsub(/'/, "''")
  end
  
  private

  def lights_cookie
    if cookies[:lights].nil?
      @lights = true
    else
      if cookies[:lights] == "true"
        @lights = true
      else
        @lights = false
      end
    end
  end
  
  def redirect_from_www
    #if Rails.env == 'production' and !/^www/.match(request.host)
      #redirect_to request.protocol + "www." + request.host_with_port + request.url
    #end
  end
  
  def meta_defaults
    @users_count = User.count
    @games_count = Game.count
    @categories = Category.all
    @topics = Topic.all
  end
  
  def set_previous_location
    store_location unless request.xhr? or controller_name =~ /session|account|messages/
  end
  
  # For use with sorting lists of games
  def get_sort_conditions(conditions)
    conditions = "published" if params[:sort].nil?
    case conditions
            when "title" then "title ASC"
            when "rating" then "rating_avg DESC, rating_count DESC"
            when "views" then "games.views DESC"
            when "published" then "games.created_at DESC"
            when "title_reverse" then "title DESC"
            when "rating_reverse" then "rating_avg ASC, rating_count ASC"
            when "views_reverse" then "games.views ASC"
            when "published_reverse" then "games.created_at ASC"
            end
  end
end
