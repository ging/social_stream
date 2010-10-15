module SocialStream
  module Rails
    # Common methods for Rails::Railtie and Rails::Engine
    module Common #:nodoc:
      class << self
        def inflections
          ActiveSupport::Inflector.inflections do |inflect|
            inflect.singular /^([Tt]ie)s$/, '\1'
          end
        end

        def included(base)
          base.class_eval do
            config.generators.authentication :devise

            config.to_prepare do
              %w( actor activity_object ).each do |supertype|
                supertype.classify.constantize.load_subtype_features
              end

            # https://rails.lighthouseapp.com/projects/8994/tickets/1905-apphelpers-within-plugin-not-being-mixed-in
              ApplicationController.helper ActivitiesHelper
            end

            initializer "social_stream.inflections" do
              Common.inflections
            end
          end
        end
      end
    end
  end
end

