# Load Devise constant
require 'devise'
require 'social_stream/rails/common'
File.expand_path(__FILE__) =~ /#{ File.join('vendor', 'plugins') }/ ?
  require('social_stream/rails/railtie') :
  require('social_stream/rails/engine')

require 'social_stream/rails/routes'

module SocialStream
  module Rails #:nodoc:
  end
end
