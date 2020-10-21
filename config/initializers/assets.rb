# Version of your assets, change this if you want to expire all your assets
Rails.application.config.assets.version = '1.4'

# Enable the asset pipeline
Rails.application.config.assets.enabled = true

Rails.application.config.assets.js_compressor = Uglifier.new( harmony: true ) # ES6 support

Rails.application.config.assets.precompile += %w(*.svg *.eot *.woff *.ttf *.gif *.png *.ico)
Rails.application.config.assets.precompile << /\A(?!active_admin).*\.(js|css)\z/
