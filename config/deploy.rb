# config valid only for Capistrano 3.1
lock '3.2.1'
set :application, 'multilisting'
set :repo_url, 'git@github.com:teacplusplus/nmir.git'

#https://github.com/teacplusplus/nmir.git
# Default branch is :master
#ask :branch, :master

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/tea/var/www/multilisting'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3




namespace :deploy do
  desc 'Create symlink'
  task :symlink do
    on roles(:all) do
      execute "cp #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
  end

  desc 'Start unicorn server'
  task :start do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, "exec unicorn_rails -c config/unicorn.rb -E production"
        end
      end
    end
  end

  desc 'Stop unicorn server'
  task :stop do
    on roles(:all) do
      execute "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
    end
  end


   after :deploy, 'deploy:symlink'
   after :deploy, 'deploy:start'
end




