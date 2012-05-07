SocialStream::Components.each do |component|
  require "social_stream/migrations/#{ component }"

  "SocialStream::Migrations::#{ component.to_s.camelcase }".constantize.new.up
end
