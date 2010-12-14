# Use migration template
path = %w( .. .. .. lib generators social_stream templates migration )
path.unshift File.dirname(__FILE__)

require File.join(*path)

ActiveRecord::Schema.define(:version => 0) do
  CreateSocialStream.up
end
