# A {Tie} is a link between two {Actor Actors},
# and therefore, two {SocialStream::Models::Subject Subjects}.
#
# It is made up with a {Contact} and a {Relation}. The {Contact} defines the sender
# or {Actor} that declares the link, and the receiver or {Actor} that is pointed by
# the declaration. The {Relation} defines the type of link (friend, colleague,
# {Relation::Reject}, etc)

# = Authorization
# When an {Actor} establishes a {Tie} with other, she is granting a set of
# {Permission Permissions} to them (posting to her wall, reading her posts, etc..)
# The set of {Permission Permissions} granted are associated with the {Relation} of
# the {Tie}.
#
# = Scopes
# There are several scopes defined:
#
# sent_by(actor):: ties whose sender is actor
# received_by(actor):: ties whose receiver is actor
# sent_or_received_by(actor):: the union of the former
# related_by(relation):: ties with this relation. Accepts relation, relation_name,
#                        integer, array
#
class Tie < ActiveRecord::Base
  belongs_to :contact, :counter_cache => true

  has_one :sender,   :through => :contact
  has_one :receiver, :through => :contact

  belongs_to :relation
  has_many :permissions, :through => :relation

  scope :allowing, lambda { |action, object|
    joins(:relation).
      merge(Relation.allowing(action, object))
  }

  scope :recent, order("ties.created_at DESC")

  scope :sent_by, lambda { |a|
    joins(:contact).merge(Contact.sent_by(a))
  }
  scope :received_by, lambda { |a|
    joins(:contact).merge(Contact.received_by(a))
  }

  scope :sent_or_received_by, lambda { |a|
    joins(:contact).merge(Contact.sent_or_received_by(a))
  }

  scope :related_by, lambda { |r|
    if r.present?
      where(:relation_id => Relation.normalize_id(r))
    end
  }

  scope :positive, lambda {
    joins(:relation).
      merge(Relation.positive)
  }

  scope :with_permissions, lambda { |action, object|
    joins(:relation => :permissions).
      where('permissions.action' => action).
      where('permissions.object' => object)
  }

  validates_presence_of :contact_id, :relation_id

  validate :relation_belongs_to_sender

  after_create  :create_activity
  after_create  :set_follow_action
  after_destroy :unset_follow_action

  def relation_name
    relation.try(:name)
  end

  def sender_subject
    sender.subject
  end

  def receiver_subject
    receiver.subject
  end

  # The {Tie} is positive if its {Relation} is
  def positive?
    relation.positive?
  end

  # Does this {Tie} have positive {Tie ties} in the other way?
  def positive_replied?
    contact.positive_replied?
  end

  # This {Tie} is {#positive? positive} and {#positive_replied? positive replied}
  def bidirectional?
    positive? && positive_replied?
  end

  # after_create callback
  #
  # Create the {Actor}'s follower_count
  def set_follow_action
    return if contact.reflexive? ||
              !relation.permissions.include?(Permission.follow.first)

    action = sender.action_to!(receiver)

    return if action.follow?

    action.update_attribute(:follow, true)
  end

  # after_remove callback
  #
  # Decrement the {Actor}'s follower_count
  #
  # This method needs to be public to be call from {Contact}'s after_remove callback
  def unset_follow_action
    return if contact.reflexive? ||
              !relation.permissions.include?(Permission.follow.first)

    # Because we allow several ties from the same sender to the same receiver,
    # we check the receiver does not still have a follower tie from this sender
    return if Tie.sent_by(sender).
                  received_by(receiver).
                  with_permissions('follow', nil).
                  present?

    action = sender.action_to!(receiver)

    action.update_attribute(:follow, false)
  end

  private

  # before_create callback
  #
  # Create contact activity if this is the first tie
  def create_activity
    return if contact.reload.ties_count != 1 || relation.is_a?(Relation::Reject)

    Activity.create! :author        => contact.sender,
                     :user_author   => contact.user_author,
                     :owner         => contact.receiver,
                     :relation_ids  => contact.receiver.activity_relation_ids,
                     :activity_verb => ActivityVerb[contact.verb]
  end

  def relation_belongs_to_sender
    errors.add(:relation, "must belong to sender") unless
      relation.is_a?(Relation::Single) ||
        contact.sender_id == relation.actor_id
  end
end

ActiveSupport.run_load_hooks(:tie, Tie)
