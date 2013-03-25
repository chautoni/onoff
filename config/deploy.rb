require "bundler/capistrano"

# Automatically precompile assets
load "deploy/assets"

# RVM integration
require "rvm/capistrano"

# Target ruby version
set :rvm_ruby_string, '1.9.3'

# User specific RVM installation
set :rvm_type, :user

server "198.211.127.54", :web, :app, :db, primary: true

set :application, "onoff"
set :user, "kane"
set :deploy_to, "/home/#{user}/code/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:TrangHo/#{application}.git"
set :branch, "vps"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/conf/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  desc "Fix permission"
  task :fix_permissions, :roles => [ :app, :db, :web ] do
    run "#{try_sudo} chmod 777 -R #{current_path}/log"
  end

  after "deploy:finalize_update", "deploy:symlink_config"
  after "deploy:update_code", 'deploy:fix_permissions'
end
