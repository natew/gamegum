class AccountController < ApplicationController
  before_filter :login_required
  before_filter :set_title, :except => ['index', 'edit']
  
  def index
    title = 'Account'
    @pulse = Pulse.get(:users => current_user.friends, :limit => 8)
  end
  
  def profile
    unless params[:user].nil?
      if current_user.update_attributes(params[:user])
        flash[:notice] = 'Updated profile!'
      end
    end
  end
  
  def edit
    unless params[:user].nil?
      if current_user.email != params[:user][:email]
        current_user.email_confirmed = false
        current_user.save
      end
    
      if current_user.update_attributes(params[:user])
        flash[:notice] = 'Updated account!'
      end
    end
  end
  
  def games
    sort   = get_sort_conditions(params[:sort])
    @games = current_user.games.paginate :order => sort, :page => params[:page], :per_page => 16
    @edit  = true
  end
  
  def comments
    @edit = true
    @comments = current_user.comments.paginate(
    			:order => 'created_at DESC',
    			:page => params[:page],
    			:per_page => 8,
    			:include => [:game,:user]
    		)
  end
  
  def posts
    @posts = current_user.posts.paginate(
               :order => 'created_at DESC',
               :page => params[:page],
               :per_page => 16,
               :include => :discussion
             )
  end
  
  def resend
    UserMailer.welcome_email(current_user).deliver unless current_user.email_confirmed
    flash[:notice] = 'Confirmation email resent!'
    redirect_to '/account'
  end
  
  def threads
    @threads = current_user.threads.paginate :order => 'created_at DESC', :page => params[:page], :per_page => 8
  end
  
  def favorites
    @favorites = current_user.favorite_games.paginate :order => 'games.created_at DESC', :page => params[:page], :per_page => 8
    @user = current_user
    render :template => 'users/favorites'
  end
  
  def friends
    @friends = current_user.friends.paginate :order => 'created_at DESC', :page => params[:page], :per_page => 16
    @user = current_user
    render :template => 'users/friends'
  end
  
  private
  def set_title
    title = 'My ' + action_name.titlecase
  end
end
