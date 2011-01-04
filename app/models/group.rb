class Group < ActiveRecord::Base
  def followers
    subjects(:subject_type => :user, :direction => :senders)
  end
end
