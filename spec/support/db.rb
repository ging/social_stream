gems = %w{ documents events linkser }

gems.each do |g|
  require "social_stream/migrations/#{ g }"
end

gems.unshift("base")

gems.reverse.each do |g|
  "SocialStream::Migrations::#{ g.camelize }".constantize.new.down
end

gems.each do |g|
  "SocialStream::Migrations::#{ g.camelize }".constantize.new.up
end
