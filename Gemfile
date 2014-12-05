source 'http://rubygems.org'

# App
gem 'rails', '~> 3.2'

# Plugins
gem 'will_paginate', '~> 3.0'
gem 'mimetype-fu'
gem 'yaml_db'
gem 'textacular', '~> 3.0', :require => 'textacular/rails'
gem 'acts-as-taggable-on', '~> 2.2.2'
gem 'headjs-rails'
gem "paperclip", '~> 3.0'
gem 'crack'
gem 'aws-ses', '~> 0.4.4', :require => 'aws/ses'
gem 'aws-sdk'
gem 'ruby-imagespec', :github => 'natew/ruby-imagespec'
gem 'typus', :github => 'fesplugas/typus'
# gem 'turbo-sprockets-rails3'

gem 'memcached'
gem 'dalli'

platforms :jruby do
  gem 'trinidad'
  # gem 'therubyrhino'
  gem 'activerecord-jdbcpostgresql-adapter'
end

platform :ruby do
  gem 'pg', '~> 0.14'
  gem 'unicorn'
end

group :development do
  gem 'capistrano'
  gem 'fastercsv'
end

# Assets
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

# jQuery
gem 'jquery-rails'