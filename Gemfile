source 'https://rubygems.org'

ruby '2.3.0'

gem 'rails', '4.0.1'

gem 'rack-cors'

# CAS authentication
gem 'devise', '1.5.0'
# Authorization
gem 'cancan'

gem 'intercom-rails'

# DB
gem 'sqlite3', '1.3.11'
gem 'pg', '~> 0.20'

# Inplace editor
gem 'best_in_place', :github => 'afalkear/best_in_place_post'
gem 'padma-assets', '0.2.30'

gem 'appsignal', '~> 2.8'

group :production do
  gem 'rails_12factor'
  gem 'dalli'
end

gem 'daemons'
gem 'delayed_job_active_record', '~> 4.1.1'

#gem 'logical_model', '0.6.4'
gem 'messaging_client'
gem 'accounts_client', '0.2.38'
gem 'kaminari'
gem 'ransack'
gem 'activerecord-session_store'

# Gems used only for assets and not required
# in production environments by default.
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier', '~> 3.2'
gem 'jquery-rails'
gem "execjs"
gem 'less-rails-bootstrap'
gem "therubyracer", '0.12.2'

group :development, :test do
  gem "rspec-rails"
  gem "shoulda", require: false
  gem "shoulda-matchers"
  gem "factory_bot_rails"
  gem "guard-rspec"
  gem "libnotify"
  gem 'byebug'
end

group :doc do
  gem "yard", "~> 0.8.3"
  gem 'yard-restful'
  gem 'redcarpet'
end

gem 'rake', '< 12'

group :development do
  gem 'subcontractor', '>= 0.6.1'
  gem 'foreman'
  gem 'git-pivotal-tracker-integration'
  gem 'padma-deployment'
  gem 'better_errors'
  gem 'binding_of_caller'
end
