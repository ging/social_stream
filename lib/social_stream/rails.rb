# Database foreign keys
require 'foreigner'
# jQuery
require 'jquery-rails'
# Permalinks:
require 'stringex'
# Hierarchical relationships in Relation:
require 'nested_set'
# Hierarchical relationships in Activity:
require 'ancestry'
# User authentication
require 'devise'
# Authorization
require 'cancan'
# REST controllers
require 'inherited_resources'
# Logo attachments
require 'paperclip'
require 'paperclip/social_stream'
# Pagination
require 'will_paginate'

require 'social_stream/rails/common'
File.expand_path(__FILE__) =~ /#{ File.join('vendor', 'plugins') }/ ?
  require('social_stream/rails/railtie') :
  require('social_stream/rails/engine')

module SocialStream
  module Rails #:nodoc:
  end
end
