class FavoritesController < ApplicationController
  before_filter :login_required
  
  def create
    @favorite = current_user.favorites.new(:game_id => params[:id])
    if @favorite.save
      render_on('remove')
    else
      render_on('add')
    end
  end
  
  def destroy
    current_user.favorites.find_by_game_id(params[:id]).destroy
    render_on('add')
  end
  
  private
  def render_on(type)
    if request.xml_http_request?
      render :partial => type, :locals => { :game_id => params[:id].to_i }
    else
      respond_to do |format|
        format.html do
          @game = Game.find(params[:id])
          flash[:notice] = 'Favorite has been ' + ((type === 'add') ? 'added' : 'removed')
          redirect_to @game
        end
      end
    end
  end
end
