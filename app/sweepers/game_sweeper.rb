class GameSweeper < ActionController::Caching::Sweeper
  observe Game
  
  def after_create(game)
    expire_fragment 'index_categories'
    expire_fragment 'index_new_and_popular'
    
    expire_action :action => :index
    expire_action :action => :category
    expire_action :action => :viewed
    expire_action :action => :rated
    expire_action :action => :discussed
    expire_action :action => :favorites
  end
  
  def after_update(game)
    expire_action :action => :index
    expire_action :action => :viewed
  end
end