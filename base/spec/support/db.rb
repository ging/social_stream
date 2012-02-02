require 'social_stream/migrations/base'

ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.drop_table t
end

SocialStream::Migrations::Base.new.up

require File.expand_path("../../dummy/db/seeds", __FILE__)
