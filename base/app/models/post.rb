class Post < ActiveRecord::Base
  include SocialStream::Models::Object

  alias_attribute :text, :description
  validates_presence_of :text

  define_index do
    indexes activity_object.description

    has created_at
  end

  def title
    description.truncate(30, :separator =>' ')
  end

end
