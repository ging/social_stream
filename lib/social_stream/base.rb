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

      initializer "social_stream-base.controller_helpers" do
        ActiveSupport.on_load(:action_controller) do
          include SocialStream::Controllers::Helpers
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
    end
  end
end
