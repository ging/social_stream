require 'social_stream/migrations/documents'

ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.drop_table t
end

SocialStream::Migrations::Base.new.up
SocialStream::Migrations::Documents.new.up
