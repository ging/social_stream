ActiveSupport::Inflector.inflections do |inflect|
  inflect.singular /^([Tt]ie)s$/, '\1'
end

Rails.application.config.to_prepare do
  %w( actor activity_object ).each do |supertype|
    supertype.classify.constantize.load_subtype_features
  end
end

