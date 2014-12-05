class PostsController < ApplicationController
  before_filter :get_permission_and_discussion, :only => [:new, :create]
  
  def create
    @post = @discussion.posts.new(params[:post].merge(:user => current_user))
    
    if @post.save and !@cant_submit
      redirect_to topic_discussion_path(@discussion.topic, @discussion), :notice => 'Reply posted!'
    else
      redirect_to topic_discussion_path(@discussion.topic, @discussion), :notice => 'Error (Email not active?)'
    end
  end
  
  private
  
  def get_permission_and_discussion
    @cant_submit = true if !logged_in? or !current_user.email_confirmed
    @discussion = Discussion.find(params[:discussion].to_i)
  end
end
