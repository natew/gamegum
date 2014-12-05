class DiscussionsController < ApplicationController
  before_filter :load_topics
  before_filter :get_permission_and_topic, :only => [:new, :create]
  
  def index
  end
  
  def new
    @discussion = Discussion.new
  end
  
  def create
    @discussion = Discussion.new(params[:discussion])
    @discussion.user = current_user
    
    if @discussion.save and !@cant_submit
      redirect_to [@discussion.topic,@discussion], :notice => 'Thread posted!'
    else
      render :action => 'new'
    end
  end
  
  def edit
    if logged_in? and (current_user.is_admin? or @discussion.user == current_user)
      @discussion = Discussion.find(params[:id])
      @topic = @discussion.topic
    else
      redirect_to '/'
    end
  end
  
  def update
    @discussion = Discussion.find(params[:id])

    if @discussion.update_attributes(params[:discussion])
      redirect_to @discussion, :notice => 'Successfully edited!'
    else
      render :action => 'edit'
    end
  end
  
  def show
    @discussion = Discussion.find(params[:id])
    @posts = Post.where(["discussion_id = ?",  @discussion.id])
    @post = Post.new
  end
  
  private
  
  def load_topics
    @topics = Topic.find(:all)
  end
  
  def get_permission_and_topic
    @cant_submit = true if !logged_in? or !current_user.email_confirmed
    topic_title = params[:topic_id].gsub(/-/,' ').titleize
    @topic = Topic.find_by_title(topic_title)
  end
end
