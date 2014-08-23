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

desc 'Create symlink'
task :symlink do
  on roles(:all) do
    execute "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end


desc 'Restart application'
task :start do
  on roles(:all) do
    execute "bundle exec unicorn_rails -c /home/tea/var/www/multilisting/current/config/unicorn.rb -E production"
  end
end

after :finishing, 'deploy:cleanup'
after :finishing, 'deploy:restart'

after :updating, 'deploy:symlink'

before :setup, 'deploy:starting'
before :setup, 'deploy:updating'
before :setup, 'bundler:install'

after :setup, 'deploy:start'