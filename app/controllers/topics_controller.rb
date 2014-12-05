class TopicsController < ApplicationController
  before_filter :load_topics
  
  def index
    @recently = Discussion.order('created_at desc').limit(20)
    @pulse = Pulse.find( :all, :include => [:user, :game], :limit => 35, :order => "created_at DESC" )
  end
  
  def show
    title = params[:id].gsub(/-/,' ')
    @topic = Topic.where(["LOWER(title) = ?", title]).first
    @discussions = Discussion.paginate(
                      :conditions => "topic_id = #{@topic.id}",
                      :order => 'sticky desc, created_at desc',
                      :page => params[:page],
                      :per_page => 10
                      )
  end
  
  private
  def load_topics
    @topics = Topic.find(:all)
  end
end
