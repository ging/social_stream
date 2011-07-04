class Post < ActiveRecord::Base
  include SocialStream::Models::Object

  validates_presence_of :text
end
