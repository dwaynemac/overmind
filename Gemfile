source 'https://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# CAS authentication
gem 'devise', '1.5.0'
gem 'devise_cas_authenticatable', '1.0.0.alpha13'

gem 'sqlite3', :group => [:development, :test]
gem 'pg', :group => :production

gem 'cancan'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end
gem "twitter-bootstrap-rails"
gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

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
