ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.drop_table t
end

gems = %w{ documents events linkser presence }

gems.each do |g|
  require "social_stream/migrations/#{ g }"
end

gems.unshift("base")

gems.each do |g|
  "SocialStream::Migrations::#{ g.camelize }".constantize.new.up
end

# In Rails 3.2.0, we need to reload the database schema
#
# Some models are loaded before the database is created,
# reporting their table does not exist in specs
ActiveRecord::Base.descendants.map(&:reset_column_information)
