ActiveSupport::Inflector.inflections do |inflect|
  inflect.singular /^([Tt]ie)s$/, '\1'
end

Rails.application.config.to_prepare do
  %w( actor activity_object ).each do |supertype|
    SocialStream.__send__(supertype.pluralize).each do |a|
      a.to_s.classify.constantize.class_eval do
        include "ActiveRecord::#{ supertype.classify }".constantize
      end
    end
  end
end


