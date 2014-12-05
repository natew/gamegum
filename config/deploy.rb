require 'bundler/capistrano'
load 'deploy/assets'

# Pretty colors
require 'capistrano_colors'

# rbenv and ssh forwarding
set :default_environment, { 'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH" }
set :default_run_options, { :pty => true, :shell => '/bin/zsh' }
set :ssh_options, { :forward_agent => true }

set :scm_verbose, true
set :scm, :git
set :branch, 'master'

set :keep_releases, 2
set :use_sudo, false
set :deploy_via, :remote_cache

set :user, ""
set :application, "gamegum"
set :domain, ""
set :repository,  "ssh://#{user}@#{domain}/var/git/#{application}.git"
set :deploy_to, "/var/www/#{application}.com/web"
set :rails_env, 'production'

set :unicorn_config, "#{current_path}/config/unicorn/production.rb"
set :unicorn_binary, "bundle exec unicorn_rails -c #{unicorn_config} -E #{rails_env} -D"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

role :web, domain
role :app, domain
role :db,  domain, :primary => true # This is where Rails migrations will run

after 'deploy:update', 'deploy:cleanup'

namespace :deploy do
  task :force_restart, :roles => :app, :except => { :no_release => true } do
    run "if [ -f #{unicorn_pid} ]; then kill -s USR2 `cat #{unicorn_pid}`; fi"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end

  task :stop, :roles => :app, :except => { :no_release => true } do
    run "if [ -f #{unicorn_pid} ]; then kill -s QUIT `cat #{unicorn_pid}`; fi"
  end

  task :start, :roles => :app do
    run "cd #{current_path} && #{unicorn_binary}"
  end
end