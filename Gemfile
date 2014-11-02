source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.0'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
gem 'bootstrap-sass', '~> 3.1.1'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
gem "slim-rails"
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

gem 'rails_admin'

#sphinx
gem 'mysql2'
gem 'thinking-sphinx'
gem 'ts-datetime-delta', '~> 2.0.0',
    :require => 'thinking_sphinx/deltas/datetime_delta'
gem 'joiner', '0.3.1'
#gem 'will_paginate'
gem 'sanitize-rails', require: 'sanitize/rails'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# gem 'jquery-ui-rails'
gem 'nested_form'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'devise'

gem 'cancancan', '~> 1.9'

# uploaders
gem 'carrierwave'
gem 'mini_magick'

# tools
gem 'russian', '~> 0.6.0'

group :production do
  # Use unicorn as the app server
  gem 'unicorn'
end

# Use Capistrano for deployment
group :development do
  gem 'rack-mini-profiler'
  gem 'capistrano', '~> 3.2.0'
  # gem 'capistrano-rails'
  #gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'lol_dba'
  gem 'annotate'
end

group :development, :test do
  gem 'faker'
  gem 'rspec-rails', '~> 3.0.0'
  gem 'factory_girl_rails', '~> 4.0'
end

group :test do
  gem 'capybara'
#  gem 'selenium-webdriver'
end

# Use debugger
#gem 'debugger', group: [:development, :test]


#DBF is a small fast library for reading dBase, xBase, Clipper and FoxPro database files
gem 'dbf'

#Whenever is a Ruby gem that provides a clear syntax for writing and deploying cron jobs.
gem 'whenever', '~> 0.9.0', :require => false


#Paperclip is intended as an easy file attachment library for Active Record.
gem "paperclip", "~> 4.2"
gem 'jquery-fileupload-rails'


#Generates javascript file that defines all Rails named routes as javascript helpers
gem "js-routes"

gem "nokogiri"



