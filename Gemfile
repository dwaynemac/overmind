source 'https://rubygems.org'

gem 'rails', '3.2.8'

# CAS authentication
gem 'devise', '1.5.0'
gem 'devise_cas_authenticatable', '1.0.0.alpha13'
# Authorization
gem 'cancan'

# DB
gem 'sqlite3', :group => [:development, :test]
gem 'pg', :group => :production

gem 'logical_model', '~> 0.4.1'
gem 'accounts_client', '~> 0.0.5'
gem 'kaminari'
gem 'ransack'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end
gem 'jquery-rails'

gem "twitter-bootstrap-rails"

group :assets do
  gem "execjs"
  gem "therubyracer"
end

group :development, :test do
  gem "rspec-rails"
  gem "shoulda"
  gem "factory_girl_rails"
  gem "guard-rspec"
  gem "libnotify"
  gem "yard", "~> 0.7.4"
  gem "yard-rest", :git => "git@github.com:dwaynemac/yard-rest-plugin.git"
end

group :development do
  gem 'foreman'
end
