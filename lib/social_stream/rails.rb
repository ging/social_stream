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

File.expand_path(__FILE__) =~ /^#{ Gem.path }/ ?
  require('social_stream/rails/engine') :
  require('social_stream/rails/railtie')

module SocialStream
  module Rails #:nodoc:
  end
end
