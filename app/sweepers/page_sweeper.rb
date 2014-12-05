class PageSweeper < ActionController::Caching::Sweeper
  observe Page
  
  def after_create(page)
    expire_fragment 'index_featured_pages'
    expire_action :controller => 'games', :action => :featured
  end
  
  def after_update(page)
    expire_fragment 'index_featured_pages'
    expire_action :controller => 'games', :action => :featured
  end
end