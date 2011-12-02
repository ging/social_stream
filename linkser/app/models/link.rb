class Link < ActiveRecord::Base
  include SocialStream::Models::Object

  validates_presence_of :url

  define_index do
    indexes title
    indexes description
    indexes url

    has created_at
  end

end
