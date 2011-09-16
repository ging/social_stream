RSpec.configure do |config|
  # Add authentication helpers
  config.include Devise::TestHelpers, :type => :controller
end
