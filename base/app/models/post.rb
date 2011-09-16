class Post < ActiveRecord::Base
  include SocialStream::Models::Object

  validates_presence_of :text
  
    define_index do
    indexes text
    
    has created_at
  end
  
end
