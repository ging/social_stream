# Database foreign keys
require 'foreigner'
# jQuery
require 'jquery-rails'
# Permalinks:
require 'stringex'
# Hierarchical relationships in Activity and Relation:
require 'ancestry'
# Messages
require 'mailboxer'
# User authentication
require 'devise'
# Authorization
require 'cancan'
# REST controllers
require 'inherited_resources'
# Scopes in controllers
require 'has_scope'
# Logo attachments
require 'paperclip'
require 'paperclip/social_stream'
require 'avatars_for_rails'
# Pagination
require 'will_paginate'
# Oauth
require 'omniauth/oauth'
# CSS themes
require 'rails_css_themes'
#Tags
require 'acts-as-taggable-on'
#Files
#require 'social_stream-files'
# HTML forms
require 'formtastic'

module SocialStream
  class Engine < ::Rails::Engine #:nodoc:
    config.app_generators.authentication :devise
    config.app_generators.messages :mailboxer
    config.app_generators.taggings :acts_as_taggable_on

    config.to_prepare do
      %w( actor activity_object ).each do |supertype|
        supertype.classify.constantize.load_subtype_features
      end

      # https://rails.lighthouseapp.com/projects/8994/tickets/1905-apphelpers-within-plugin-not-being-mixed-in
      ApplicationController.helper ActivitiesHelper
      ApplicationController.helper SubjectsHelper
      ApplicationController.helper LocationHelper
      ApplicationController.helper ToolbarHelper
      ApplicationController.helper ProfilesHelper
      ApplicationController.helper PermissionsHelper
      ApplicationController.helper NotificationsHelper
      ApplicationController.helper ContactsHelper
      
      ActsAsTaggableOn::TagsHelper
    end

    initializer "social_stream.inflections" do
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.singular /^([Tt]ie)s$/, '\1'
      end
    end

    initializer "social_stream.mime_types" do
      Mime::Type.register 'application/xrd+xml', :xrd
    end

    initializer "social_stream.controller_helpers" do
      ActiveSupport.on_load(:action_controller) do
        include SocialStream::Controllers::Helpers
      end
    end

    initializer "social_stream.avatars_for_rails" do
      AvatarsForRails.setup do |config|
        config.avatarable_model = :actor
        config.current_avatarable_object = :current_actor
        config.avatarable_filters = [:authenticate_user!]
        config.avatarable_styles = { :representation => "20x20>",
                                     :contact        => "30x30>",
                                     :actor          => '35x35>',
                                     :profile        => '94x94'}
      end
    end

  end
end
