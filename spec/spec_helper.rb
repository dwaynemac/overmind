RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.include FactoryBot::Syntax::Methods
  config.include Devise::TestHelpers, :type => :controller
  config.include Shoulda::Matchers

  config.infer_spec_type_from_file_location!
  # Only run specs marked with :focus in metadata or all specs if none with :focus is found.
  # config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end

module AuthHelper
 def login_user
  @request.env["devise.mapping"] = Devise.mappings[:user]
  user = FactoryBot.create(:user)
  # user.confirm # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
  sign_in user
 end
end
