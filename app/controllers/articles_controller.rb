class ArticlesController < ApplicationController
  before_filter :get_recent

  def index
    @articles = Article.paginate(:page => params[:page], :per_page => 6)
  end
  
  def show
    @article = Article.find(params[:id])
  end
  
  private
  
  def get_recent
    @recent = Article.limit(6)
  end
end
