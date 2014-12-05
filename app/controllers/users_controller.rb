class UsersController < ApplicationController
  before_filter :load_user, :except => [:create, :new, :activate, :index, :account]
  before_filter :check_url, :only => [:show]
  before_filter :logout_required, :only => [:create, :new]
  before_filter :get_favs_and_subs, :only => [:show, :favorites, :submissions]

  def index
    @users = User.paginate :order => 'users.gumpoints DESC', :page => params[:page], :per_page => 25
    @page = params[:page].nil? ? 1 : params[:page].to_i
  end

  def new
    if request.xml_http_request?
      unless params[:login].nil?
        if User.count(:conditions => { :login => params[:login] }).zero?
          render :text => 'Username <span>available</span>'
        else
          render :text => 'Username <span>already taken</span>'
        end
      end
    end
  end

  def show
    @pulse = Pulse.find_all_by_user_id(@cid, :include => [:game], :limit => 16)
    @cuser.update_attribute(:views, @cuser.views.next)

    respond_to do |format|
      format.html
      format.rss { render :layout => false }
    end
  end

  def create
    cookies.delete :auth_token
    @user = User.new(params[:user])

    if @user.save
      self.current_user = @user
      redirect_to @user
      UserMailer.welcome_email(@user).deliver
      flash[:notice] = "Welcome!"
    else
      render :action => 'new'
      flash[:notice] = "Error signing up!"
    end
  end

  def activate
    @user = User.find(params[:id].to_i)

    if @user.email_confirmed?
      @message = 'Account has already been activated!'
    else
      verify = Digest::SHA1.hexdigest(@user.email + '328949126')

      if verify == params[:key]
        if @user.update_attribute(:email_confirmed, true)
          @message = 'Congrats!  Your account has been activated'
        else
          @message = 'Error activating account.  Please contact support.'
        end
      else
        @message = 'Sorry!  Your verification key does not match' + verify
      end
    end
  end

  def update
    if current_user.update_attributes(params[:user])
      redirect_to 'account/profile', :notice => 'Updated successfully'
    else
      render :action => 'profile'
    end
  end

  def favorites
    @favorites = @cuser.favorite_games.paginate :order => 'games.created_at DESC', :page => params[:page], :per_page => 15
  end

  def friends
    @friends = @cuser.friends.paginate :order => 'created_at DESC', :page => params[:page], :per_page => 16
  end

  def submissions
    @submissions = @cuser.games.paginate :order => 'games.created_at DESC', :page => params[:page], :per_page => 15
  end

  private

  def load_user
    @cid = params[:id].split('/')[0]
    @cuser = User.find(@cid)
  end

  def check_url
  	slug = params[:id].split('/')[1]

  	if slug =~ /(favorites|submissions|friends|messages)/
  	  render :action => slug
  	else
      redirect_to url_for(@cuser) if slug != @cuser.slug
    end
  end

  def get_favs_and_subs
    @latest_submissions = @cuser.games.find(:all, :order => 'games.created_at DESC', :limit => 5)
    @latest_favorites = @cuser.favorite_games.find(:all, :order => 'games.created_at DESC', :limit => 5)
  end
end
