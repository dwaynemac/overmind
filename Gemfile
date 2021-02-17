source 'https://rubygems.org'

ruby '2.3.8'

gem 'rails', '4.1.2'

gem 'rack-cors', '~> 1.0.3'

# CAS authentication
gem 'devise', '3.4.1'
# Authorization
gem 'cancan', '~> 1.6.10'

gem 'intercom-rails', '~> 0.4.2'

# DB
gem 'sqlite3', '1.3.11'
gem 'pg', '~> 0.20'

# Inplace editor
gem 'best_in_place', :github => 'afalkear/best_in_place_post'
gem 'padma-assets', '0.2.30'

gem 'appsignal', '~> 2.8'

group :production do
  gem 'rails_12factor', '~> 0.0.3'
  gem 'dalli', '~> 2.7.11'
end

gem 'daemons', '~> 1.3.1'
gem 'delayed_job_active_record', '~> 4.1.1'

#gem 'logical_model', '0.6.4'
gem 'messaging_client', '0.2.0'
gem 'accounts_client', '0.2.38'
gem 'kaminari', '~> 0.13.0'
gem 'ransack', '~> 1.8.10'
gem 'activerecord-session_store', '~> 1.1.3'

# Gems used only for assets and not required
# in production environments by default.
gem 'sass-rails', '~> 5.0.7'
gem 'coffee-rails', '~> 4.2.2'
gem 'uglifier', '~> 3.2'
gem 'jquery-rails', '~> 3.1.5'
gem 'jquery-ui-rails', '~> 6.0.1'
gem "execjs", '~> 2.7.0'
gem 'less-rails-bootstrap', '~> 3.3.5.0'
gem "therubyracer", '0.12.2'

group :development, :test do
  gem "rspec-rails", '~> 3.9.1'
  gem "shoulda", '~> 3.5.0', require: false
  gem "shoulda-matchers", '~> 2.6.2'
  gem "factory_bot_rails", '~> 4.11.1'
  gem "guard-rspec", '~> 4.7.3'
  gem "libnotify", '~> 0.9.4'
  gem 'byebug', '~> 11.0.1'
end

group :doc do
  gem "yard", "~> 0.8.3"
  gem 'yard-restful', '~> 1.2.4'
  gem 'redcarpet', '~> 3.5.1'
end

gem 'rake', '< 12'

group :development do
  gem 'subcontractor', '>= 0.6.1'
  gem 'foreman', '~> 0.87.2'
  gem 'git-pivotal-tracker-integration', '~> 1.4.0'
  gem 'padma-deployment', '~> 0.2.1'
  gem 'better_errors', '~> 2.8.3'
  gem 'binding_of_caller', '~> 0.8.0'
end
