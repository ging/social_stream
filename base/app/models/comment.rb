class Comment < ActiveRecord::Base
  include SocialStream::Models::Object

  validates_presence_of :text

  def parent_post
    self.post_activity.parent.direct_object
  end

  def _activity_parent_id=(id)
    self._relation_ids = Activity.find(id).relation_ids
    @_activity_parent_id = id
  end
end
