class Group < ActiveRecord::Base
  def followers
    sender_subjects(:user, :relations => 'follower')
  end
end
