# config valid only for Capistrano 3.1
lock '3.2.1'
set :application, 'multilisting'
set :repo_url, 'git@github.com:teacplusplus/nmir.git'
set :rails_env, "production"
set :migration_role, 'db'
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
set :whenever_environment, 'production'
set :domain, '192.168.0.79'
set :sidekiq_pid, '/home/tea/var/www/multilisting/run/sidekiq.pid'
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
set :unicorn_pid, "/home/tea/var/www/multilisting/run/unicorn.pid"

desc 'Dump remote production postgresql database, rsync to localhost'
task :dump do
  on roles(:all) do |_|
    download!("#{current_path}/config/database.yml", "tmp/database.yml")
    remote_settings = YAML::load_file("tmp/database.yml")["production"]
    local_settings  = YAML::load_file("config/database.yml")["development"]
    execute "export PGPASSWORD=#{remote_settings["password"]} && pg_dump --host=#{remote_settings["host"]} --port=#{remote_settings["port"]} --username #{remote_settings["username"]} --file #{current_path}/tmp/#{remote_settings["database"]}_dump --no-owner -Fc #{remote_settings["database"]}"
    run_locally do
      execute "rsync --recursive --times --rsh=ssh --compress --human-readable --progress #{fetch(:domain)}:#{current_path}/tmp/#{remote_settings["database"]}_dump tmp/"
      execute "export PGPASSWORD=\"#{local_settings["password"]}\"; dropdb -U #{local_settings["username"]} --host=#{local_settings["host"]} --port=#{local_settings["port"]} #{local_settings["database"]}"
      execute "export PGPASSWORD=\"#{local_settings["password"]}\"; createdb -U #{local_settings["username"]} --host=#{local_settings["host"]} --port=#{local_settings["port"]} -T template0 #{local_settings["database"]}"
      execute "export PGPASSWORD=\"#{local_settings["password"]}\"; pg_restore -U #{local_settings["username"]} --host=#{local_settings["host"]} --port=#{local_settings["port"]} -d #{local_settings["database"]} --no-owner -n public tmp/#{remote_settings["database"]}_dump"
    end
  end
end

namespace :deploy do

  desc 'Create symlink'
  task :symlink do
    on roles(:all) do
      execute "cp #{shared_path}/config/database.yml #{release_path}/config/database.yml"
      execute "cp #{shared_path}/config/secrets.yml #{release_path}/config/secrets.yml"
      execute "cp #{shared_path}/config/thinking_sphinx.yml #{release_path}/config/thinking_sphinx.yml"
      execute "cp #{shared_path}/config/sidekiq.yml #{release_path}/config/sidekiq.yml"

      execute :ln, '-nfs', "#{shared_path}/sphinx", "#{release_path}/db/sphinx"
      execute :mkdir, "#{release_path}/public/system/"
      execute :ln, '-nfs', "#{shared_path}/photos", "#{release_path}/public/system"
      execute :ln, '-nfs', "#{shared_path}/public/xml", "#{release_path}/public/xml"
    end
  end


  desc 'Restart unicorn'
  task :restart do
    on roles(:all) do

      if test "[ -f #{fetch(:unicorn_pid)} ]"
        execute :kill, "-QUIT `cat #{fetch(:unicorn_pid)}` 2>/dev/null; true"
        execute :rm, fetch(:unicorn_pid)
      end
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, 'exec unicorn', "-c #{release_path}/config/unicorn.rb -D -E #{fetch(:rails_env)}"
        end
      end

      if test "[ -f #{fetch(:sidekiq_pid)} ]"
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute :bundle, 'exec sidekiqctl', "stop #{fetch(:sidekiq_pid)} 60"
          end
        end
      end

      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, 'exec sidekiq', "-e #{fetch(:rails_env)} -C config/sidekiq.yml -d"
        end
      end
    end
  end




before 'deploy:compile_assets', 'deploy:symlink'

after "deploy", "deploy:migrate"
after 'deploy', 'deploy:restart'


end







