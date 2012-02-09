class Post < ActiveRecord::Base
  include SocialStream::Models::Object

  validates_presence_of :text

  define_index do
    indexes text

    has created_at
  end

  def text
    description
  end

  def text=(term)
    self.description = term
  end

  def title
    description.truncate(30, :separator =>' ')
  end

end
