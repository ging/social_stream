# Permalinks:
require 'stringex'
# Hierchical relationships in Relation and Activity:
require 'ancestry'
# User authentication
require 'devise'
# REST controllers
require 'inherited_resources'
# Logo attachments
require 'paperclip'
require 'paperclip/social_stream'
# Assets
require 'asset_bundler'

require 'social_stream/rails/common'
File.expand_path(__FILE__) =~ /#{ File.join('vendor', 'plugins') }/ ?
  require('social_stream/rails/railtie') :
  require('social_stream/rails/engine')

module SocialStream
  module Rails #:nodoc:
  end
end
