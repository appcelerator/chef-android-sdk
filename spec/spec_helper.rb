require 'chefspec'
require 'chefspec/berkshelf'

Dir['*_spec.rb'].each { |f| require File.expand_path(f) }

# RSpec.configure do |config|
#   # Specify the operating platform to mock Ohai data from (default: nil)
#   config.platform = 'mac_os_x'

#   # Specify the operating version to mock Ohai data from (default: nil)
#   config.version = '10.12'

#   # config.log_level = :debug
# end
