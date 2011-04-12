class TieActivity < ActiveRecord::Base
  belongs_to :activity
  belongs_to :tie

  after_create :disseminate

  private
  
  # Make a copy to all the ties that are both interesed and allowed to reach the activity
  def disseminate
    return unless original?

    followers = tie.followers

    # FIXME: here we need to check moderation and diffussion of the received activity.
    #
    # Sometimes, diffussion is not required, i.e. when the sender adds the receiver as contact
    # Other times, the receiver must explicitly allow to post to her wall, and the dissemination permissions
    # can control who else related with the receiver should receive the activity
    receiver_ties =
      Tie.
        with_permissions('create', 'activity').
        replying(tie)

    if receiver_ties.present?
      followers |= receiver_ties

      # Disseminate to the followers of the receiver
      receiver_ties.each do |t|
        followers |= t.followers
      end
    end

    # All the ties following the activities attached to this tie, allowed to read
    # this activity
    followers.each do |t|
      self.class.create!(:activity_id => activity_id,
                         :tie => t,
                         :original => false)
    end
  end
end
