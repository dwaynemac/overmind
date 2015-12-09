source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '3.2.8'

gem 'rack-cors'

# CAS authentication
gem 'devise', '1.5.0'
gem 'devise_cas_authenticatable', '~> 1.3'
# Authorization
gem 'cancan'

gem 'intercom-rails'

# DB
gem 'sqlite3', :group => [:development, :test]

# Inplace editor
gem 'best_in_place', :github => 'afalkear/best_in_place_post'
gem 'padma-assets', path: '~/Workspace/padma-assets' #'0.1.32'

gem 'appsignal', '0.11.14'

group :production do
  gem 'pg'
  gem 'rails_12factor'
end

gem 'logical_model', '0.6.3'
gem 'accounts_client', '0.2.15'
gem 'kaminari'
gem 'ransack'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
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

end

group :doc do
  gem "yard", "~> 0.8.3"
  gem 'yard-restful'
  gem 'redcarpet'
end

group :test do
  gem 'rake' # for travis-ci
end

group :development do
  gem 'subcontractor', '>= 0.6.1'
  gem 'foreman'

  gem 'debugger'

  gem 'git-pivotal-tracker-integration'
  gem 'padma-deployment'
  
  gem 'better_errors'
  gem 'binding_of_caller'
end
