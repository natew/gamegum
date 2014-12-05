class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article
  
  def after_create(article)
    expire_cache(article)
  end
  
  def expire_cache(article)
    expire_fragment 'index_blog'
  end
end