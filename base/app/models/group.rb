class Group < ActiveRecord::Base
  include SocialStream::Models::Subject

  attr_accessor :_participants

  delegate :description, :description=, :to => :profile!

  after_create :create_ties

  def profile!
    actor!.profile || actor!.build_profile
  end

  def followers
    contact_subjects(:subject_type => :user, :direction => :received)
  end
  
  def recent_groups
    contact_subjects(:type => :group, :direction => :sent) do |q|
      q.select("contacts.created_at").
        merge(Contact.recent)
    end
  end

  private

  # Creates ties from founder to the group, based on _relation_ids,
  # and ties from the group to founder and participants.
  def create_ties
    create_ties_from_founder
    create_ties_to_participants
  end

  # Creates the ties from the founder to the group
  def create_ties_from_founder
    _contact.sender.sent_contacts.create! :receiver_id  => actor_id,
                                          :relation_ids => _relation_ids
  end
  
  # Creates the ties from the group to the participants
  def create_ties_to_participants
    ([ _contact.sender_id, _contact.receiver_id ] | Array.wrap(@_participants)).uniq.each do |a|
      sent_contacts.create! :receiver_id => a,
                            :relation_ids => Array(relation_customs.sort.first.id)
    end
  end
end
