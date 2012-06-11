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

      initializer "social_stream-base.controller.helpers" do
        ActiveSupport.on_load(:action_controller) do
          include SocialStream::Controllers::Helpers
          include SocialStream::Controllers::CancanDeviseIntegration
          include SocialStream::Controllers::I18nIntegration
          include SocialStream::Controllers::MarkNotificationsRead
        end
      end

      initializer "social_stream-base.views.settings" do
        SocialStream::Views::Settings.module_eval do
          include SocialStream::Views::Settings::Base
        end
      end

      initializer "social_stream-base.views.sidebar" do
        SocialStream::Views::Sidebar.module_eval do
          include SocialStream::Views::Sidebar::Base
        end
      end

      initializer "social_stream-base.views.toolbar" do
        SocialStream::Views::Toolbar.module_eval do
          include SocialStream::Views::Toolbar::Base
        end
      end

      initializer "social_stream-base.avatars_for_rails" do
        AvatarsForRails.setup do |config|
          config.avatarable_model = :actor
          config.current_avatarable_object = :current_actor
          config.avatarable_filters = [:authenticate_user!]
          config.avatarable_styles = { :representation => "20x20>",
                                       :contact        => "30x30>",
                                       :actor          => '35x35>',
                                       :profile        => '119x119'}
        end
      end

      initializer "social_stream-base.mailboxer", :before => :load_config_initializers do
        Mailboxer.setup do |config|
          config.email_method = :mailboxer_email
        end
      end

      config.to_prepare do
        ApplicationController.rescue_handlers += [["CanCan::AccessDenied", :rescue_from_access_denied]]
      end
    end
  end
end
