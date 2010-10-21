class Group < ActiveRecord::Base
  validates_presence_of :name

  scope :alphabetic, includes(:actor).order('actors.name')

  def logo
    "group.png"
  end

  def followers
    sender_subjects(:user, :relations => 'follower')
  end
end
