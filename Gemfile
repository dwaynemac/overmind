source 'https://rubygems.org'

ruby '2.1.10'

gem 'rails', '3.2.8'

gem 'rack-cors'

# CAS authentication
gem 'devise', '1.5.0'
gem 'devise_cas_authenticatable', '~> 1.3'
# Authorization
gem 'cancan'

gem 'intercom-rails'

# DB
gem 'sqlite3', '~> 1.3.5', :group => [:development, :test]
gem 'pg', '~> 0.11'

# Inplace editor
gem 'best_in_place', :github => 'afalkear/best_in_place_post'
gem 'padma-assets', '0.2.30'

gem 'appsignal', '~> 2.8'

group :production do
  gem 'rails_12factor'
  gem 'dalli'
end

gem 'daemons'
gem 'delayed_job_active_record'

gem 'logical_model', '0.6.6'
gem 'messaging_client', '~> 0.1'
gem 'accounts_client', '0.2.37'
gem 'kaminari'
gem 'ransack'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '~> 3.2'
  gem 'jquery-rails'
  gem "execjs"
  gem 'less-rails-bootstrap', '~> 3.0.6'
  gem "therubyracer", '0.12.2'
end

group :development, :test do
  gem "rspec-rails"
  gem "shoulda", require: false
  gem "factory_girl_rails"
  gem "guard-rspec"
  gem "libnotify"
  gem "byebug"

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
