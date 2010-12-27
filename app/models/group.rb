class Group < ActiveRecord::Base
  def followers
    sender_subjects(:subject_type => :user)
  end
end
