class FriendsController < ApplicationController
  before_filter :login_required, :set_friend
  
  def create
    if current_user.is_pending_friend_of? @friend
      current_user.accept_friendship_with @friend
      partial = 'friend'
    elsif !current_user.is_friends_with? @friend
      current_user.request_friendship_with @friend
      partial = 'pending_friend'
      flash[:notice] = 'Friend has been added'
    else
      flash[:warning] = 'Friend already added'
    end

    if request.xml_http_request?
        render :partial => partial
    else
      redirect_to user_path
    end
  end
  
  def destroy
    if current_user.is_friends_with? @friend
      current_user.delete_friendship_with @friend
      flash[:notice] = 'Friend has been removed'
    else
      flash[:warning] = 'Friend could not be removed'
    end

    if request.xml_http_request?
      render :partial => 'add_friend'
    else
      redirect_to user_path
    end
  end
  
  private
  def set_friend
    @friend = User.find(params[:id])
  end
end
