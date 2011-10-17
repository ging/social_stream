# A {Tie} is a link between two {Actor Actors} ({Contact}) with a {Relation}.
#
# The first {Actor} is the sender of the {Tie}. The second {Actor}
# is the receiver of the {Tie}.
#
# = Tie strengh
#
# Because each {Tie} belongs to a {Relation} and {Relation Relations} have strength
# hierarchies, {Tie Ties} also have them. A {Tie} is stronger than other if its
# {Relation} is stronger than the other's. For example, if _Alice_ has a _friend_ {Tie}
# with _Bob_, and an _acquaintance_ {Tie} with _Charlie_, given that _friend_ {Relation}
# is stronger than _acquaintance_, the {Tie} with _Bob_ is stronger than the {Tie} with
# _Charlie_.
#
# = Authorization
# When an {Actor} establishes a {Tie} with other, she is granting a set of
# {Permission Permissions} to them (posting to her wall, reading her posts, etc..)
# The set of {Permission Permissions} granted are associated with the {Relation} of
# the {Tie}.
#
# Usually, stronger ties (and relations) have more permissions than weaker ones.
#
# = Scopes
# There are several scopes defined:
#
# sent_by(actor):: ties whose sender is actor
# received_by(actor):: ties whose receiver is actor
# sent_or_received_by(actor):: the union of the former
# related_by(relation):: ties with this relation. Accepts relation, relation_name,
#                        integer, array
class Tie < ActiveRecord::Base

  belongs_to :contact, :counter_cache => true

  has_one :sender,   :through => :contact
  has_one :receiver, :through => :contact

  belongs_to :relation

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

  scope :with_permissions, lambda { |action, object|
    joins(:relation => :permissions).
      where('permissions.action' => action).
      where('permissions.object' => object)
  }

  validates_presence_of :contact_id, :relation_id

  validate :relation_belongs_to_sender

  after_create  :create_activity
  after_create  :increment_follower_count
  after_destroy :decrement_follower_count

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

  private

  # before_create callback
  #
  # Create contact activity if this is the first tie
  def create_activity
    return if contact.reload.ties_count != 1 || relation.is_a?(Relation::Reject)

    Activity.create! :contact => contact,
                     :relation_ids => contact.relation_ids,
                     :activity_verb => ActivityVerb[contact.verb]
  end

  # after_create callback
  #
  # Increment the {Actor}'s follower_count
  def increment_follower_count
    return if contact.reflexive? ||
              !relation.permissions.include?(Permission.follow.first)

    # Because we allow several ties from the same sender to the same receiver,
    # we check the receiver does not already have a follower tie from this sender
    return if Tie.sent_by(sender).
                  received_by(receiver).
                  with_permissions('follow', nil).
                  where("ties.id != ?", id).
                  present?

    receiver.increment!(:follower_count)
  end

  # after_destroy callback
  #
  # Decrement the {Actor}'s follower_count
  def decrement_follower_count
    return if contact.reflexive? ||
              !relation.permissions.include?(Permission.follow.first)

    # Because we allow several ties from the same sender to the same receiver,
    # we check the receiver does not still have a follower tie from this sender
    return if Tie.sent_by(sender).
                  received_by(receiver).
                  with_permissions('follow', nil).
                  present?

    receiver.decrement!(:follower_count)
  end

  def relation_belongs_to_sender
    errors.add(:relation, "must belong to sender") unless
      contact.sender_id == relation.actor_id
  end
end
