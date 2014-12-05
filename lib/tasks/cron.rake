task :cron => :environment do
  ac = ActionController::Base.new

  # Daily cron fragment expires
  ac.expire_fragment('index_new_and_popular')
  ac.expire_fragment('index_featured_pages')
  ac.expire_fragment('index_categories')
  ac.expire_fragment('tla')
  ac.expire_fragment('index_blog')
end