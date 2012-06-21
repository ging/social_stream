class Comment < ActiveRecord::Base
  include SocialStream::Models::Object

  alias_attribute :text, :description
  validates_presence_of :text

  after_create :increment_comment_count
  before_destroy :decrement_comment_count

  define_index do
    activity_object_index
  end

  def parent_post
    self.post_activity.parent.direct_object
  end

  def title
    description.truncate(30, :separator =>' ')
  end

  private

  # after_create callback 
  # 
  # Increment comment counter in parent's activity_object with a comment
  def increment_comment_count 
    return if self.post_activity.parent.blank?
 
    self.post_activity.parent.direct_activity_object.increment!(:comment_count) 
  end 
 
  # before_destroy callback 
  # 
  # Decrement comment counter in parent's activity_object when comment is destroyed 
  def decrement_comment_count 
    return if self.post_activity.blank? || self.post_activity.parent.blank?
 
    self.post_activity.parent.direct_activity_object.decrement!(:comment_count) 
  end 

end
