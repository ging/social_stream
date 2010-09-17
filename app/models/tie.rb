# A link between two actors in a relation.
#
# The first Actor is the sender of the Tie. The second Actor is the receiver of the Tie.
#
# == Ties and Activities
# Activities are attached to ties. 
# * The sender actor is the author of the Activity. It is the user that uploads 
#   a resource to the website or the social entity that originates the activity.
# * The receiver is the target of the Activity. The wall-profile of an actor is
#   composed by the resources assigned to the ties in which the actor is the receiver.
# * The Relation sets up the mode in which the Activity is shared. It sets the rules,
#    or permissions, by which actors have access to the Activity.
class Tie < ActiveRecord::Base
  validates_presence_of :sender_id, :receiver_id, :relation_id

  belongs_to :sender,
             :class_name => "Actor",
             :include => SocialStream.actors
  belongs_to :receiver,
             :class_name => "Actor",
             :include => SocialStream.actors
  belongs_to :relation

  has_many :activities

  scope :sent_by, lambda { |a|
    where(:sender_id => Actor(a))
  }

  scope :received_by, lambda { |a|
    where(:receiver_id => Actor(a))
  }

  def sender_subject
    sender.try(:subject)
  end

  def receiver_subject
    receiver.try(:subject)
  end

  # The set of ties between sender and receiver
  #
  def relation_set(r = :nil)
    set = self.class.where(:sender_id => sender_id,
                           :receiver_id => receiver_id)

    case r
    when :nil
      set
    when String
      set.where(:relation_id => relation.mode.find_by_name(r))
    else
      set.where(:relation_id => r)
    end
  end

  # The tie with relation r inside this relation_set
  def related(r)
    relation_set(r).first
  end

  after_create :complete_weak_set

  # Access Control

  scope :with_permissions, lambda { |action, object|
    includes(:relation => :permissions).
      where('permissions.action' => action).
      where('permissions.object' => object)
  }

  scope :parameterized, lambda { |tie|
    where(tie_conditions(tie).
          or(weak_set_conditions(tie)).
          or(group_set_conditions(tie)).
          or(weak_group_set_conditions(tie)))
  }

  scope :access_set, lambda { |tie, action, object|
    with_permissions(action, object).
      parameterized(tie)
  }


  def permissions(user, action, object)
    self.class.
      sent_by(user).
      access_set(self, action, object)
  end

  def permission?(user, action, object)
    permissions(user, action, object).any?
  end

  class << self
    def tie_conditions(t)
      arel_table[:sender_id].eq(t.sender_id).and(
        arel_table[:receiver_id].eq(t.receiver_id)).and(
        arel_table[:relation_id].eq(t.relation_id)).and(
        Permission.arel_table[:parameter].eq('tie'))
    end

    def weak_set_conditions(t)
      arel_table[:sender_id].eq(t.sender_id).and(
        arel_table[:receiver_id].eq(t.receiver_id)).and(
        arel_table[:relation_id].in(t.relation.stronger_or_equal)).and(
        Permission.arel_table[:parameter].eq('weak_set'))
    end

    def group_set_conditions(t)
      arel_table[:receiver_id].eq(t.receiver_id).and(
        arel_table[:relation_id].eq(t.relation_id)).and(
        Permission.arel_table[:parameter].eq('group_set'))
    end

    def weak_group_set_conditions(t)
      arel_table[:receiver_id].eq(t.receiver_id).and(
        arel_table[:relation_id].in(t.relation.stronger_or_equal)).and(
        Permission.arel_table[:parameter].eq('weak_group_set'))
    end
  end

  private

  def complete_weak_set
    relation.weaker.each do |r|
      if relation_set(r).blank?
        relation_set.create! :relation => r
      end
    end
  end

  class << self
    def Actor(a)
      a.is_a?(Actor) ? a : a.actor
    end

    def tie_ids_query(actor)
      c = arel_table
      d = c.alias

      c.join(d).
        on(d[:sender_id].eq(actor.id).
        and(c[:receiver_id].eq(d[:receiver_id])).
        and((c[:relation_id].eq(d[:relation_id]).or(c[:relation_id].eq(0))))).
        project(c[:id]).
        to_sql
      "SELECT ties.id FROM ties INNER JOIN ties ties_2 ON ((ties_2.sender_id = #{ actor.id } AND ties_2.receiver_id = ties.receiver_id) AND (ties_2.relation_id = ties.relation_id OR ties.relation_id = #{ Relation.mode('User', 'User').find_by_name('Public').id }))"
    end
  end
end
