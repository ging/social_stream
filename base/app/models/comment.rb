class Comment < ActiveRecord::Base
  include SocialStream::Models::Object

  alias_attribute :text, :description
  validates_presence_of :text

  define_index do
    indexes activity_object.description

    has created_at
  end


  def parent_post
    self.post_activity.parent.direct_object
  end

  def _activity_parent_id=(id)
    self._relation_ids = Activity.find(id).relation_ids
    @_activity_parent_id = id
  end

  def title
    description.truncate(30, :separator =>' ')
  end
end
