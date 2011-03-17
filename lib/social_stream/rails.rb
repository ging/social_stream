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
# Messages
require 'mailboxer'
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
# Oauth
require 'omniauth/oauth'
# CSS themes
require 'rails_css_themes'

module SocialStream
  class Engine < ::Rails::Engine #:nodoc:
    config.app_generators.authentication :devise
    config.app_generators.javascript :jquery

    config.to_prepare do
      %w( actor activity_object ).each do |supertype|
        supertype.classify.constantize.load_subtype_features
      end

      # https://rails.lighthouseapp.com/projects/8994/tickets/1905-apphelpers-within-plugin-not-being-mixed-in
      ApplicationController.helper ActivitiesHelper
      ApplicationController.helper SubjectsHelper
      ApplicationController.helper TiesHelper
    end

    initializer "social_stream.inflections" do
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.singular /^([Tt]ie)s$/, '\1'
      end
    end

    initializer "social_stream.controller_helpers" do
      ActiveSupport.on_load(:action_controller) do
        include SocialStream::Controllers::Helpers
      end
    end
  end
end
