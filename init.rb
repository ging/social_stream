ActiveSupport::Inflector.inflections do |inflect|
  inflect.singular /^([Tt]ie)s$/, '\1'
end

require 'social_stream'
