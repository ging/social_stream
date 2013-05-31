module SocialStream
  # {SocialStream::Base} provides with the minimal functionality for a web-based
  # social network: {User users }, {Group groups } and the {Tie ties } between them,
  # as well as basic activities: {Post posts } and {Comment comments}
  module Base
    class Engine < ::Rails::Engine #:nodoc:
      config.app_generators.authentication :devise
      config.app_generators.messages :mailboxer
      config.app_generators.taggings :acts_as_taggable_on

      initializer "social_stream-base.inflections" do
        ActiveSupport::Inflector.inflections do |inflect|
          inflect.singular /^([Tt]ie)s$/, '\1'
        end
      end

      initializer "social_stream-base.mime_types" do
        Mime::Type.register 'application/xrd+xml', :xrd
      end

      initializer "social_stream-base.model.supertypes" do
        ActiveSupport.on_load(:active_record) do
          include SocialStream::Models::Subtype::ActiveRecord
          include SocialStream::Models::Supertype::ActiveRecord
        end
      end

      initializer "social_stream-base.model.load_single_relations" do
        SocialStream.single_relations.each{ |r| "Relation::#{ r.to_s.classify }".constantize }
      end

      initializer "social_stream-base.model.register_activity_streams" do
        SocialStream::ActivityStreams.register :person, :user
        SocialStream::ActivityStreams.register :group
        SocialStream::ActivityStreams.register :note,   :post
      end

      initializer "social_stream-base.controller.helpers" do
        ActiveSupport.on_load(:action_controller) do
          include SocialStream::Controllers::Helpers
          include SocialStream::Controllers::CancanDeviseIntegration
          include SocialStream::Controllers::I18nIntegration
          include SocialStream::Controllers::MarkNotificationsRead
        end
      end

      initializer "social_stream-base.avatars_for_rails" do
        AvatarsForRails.setup do |config|
          config.controller_avatarable = :current_actor
        end
      end

      initializer "social_stream-base.mailboxer", :before => :load_config_initializers do
        Mailboxer.setup do |config|
          config.email_method = :mailboxer_email
        end
      end

      config.to_prepare do
        ApplicationController.rescue_handlers += [["CanCan::AccessDenied", :rescue_from_access_denied]]

        # Load Relation::Public, so it is registered as descendant of Relation::Single
        # and used in ActivityObject#allowed_relations
        ::Relation::Public
      end
    end
  end
end
