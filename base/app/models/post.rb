class Post < ActiveRecord::Base
  include SocialStream::Models::Object

  alias_attribute :text, :description
  validates_presence_of :text

  define_index do
    activity_object_index
  end

  def title
    description.truncate(30, :separator =>' ')
  end

end
