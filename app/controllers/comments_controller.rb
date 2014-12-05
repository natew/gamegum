class CommentsController < ApplicationController
  before_filter :load_game
  before_filter :login_required
  
  def create
    @comment = @game.comments.new(params[:comment].merge(:user => current_user))
    
    respond_to do |wants|
      if @comment.save
        @comments = @game.comments.paginate(
                          :order => 'comments.created_at DESC',
                          :page => params[:page],
                          :per_page => 8)

        wants.js { render :partial => 'games/comment_area' }
        wants.html do
          flash[:notice] = 'Comment added'
          redirect_to @game
        end
      else
        wants.js do
          render :text => @comment.errors.full_messages * '<br />'
        end
        wants.html do
          flash[:warning] = 'Commment could not be added'
          redirect_to @game
        end
      end
    end
  end
  
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    flash[:notice] = 'Comment deleted!'
    redirect_to '/account/comments'
  end
  
  def load_game
    @game = Game.find(params[:game_id])
  end
end