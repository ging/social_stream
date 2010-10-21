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
# 
# == Inverse ties
# Relations can have its inverse. When a tie is establised, an inverse tie is establised
# as well.
#
# == Scopes
# There are several scopes defined:
# * sent_by(actor), ties whose sender is actor
# * received_by(actor), ties whose receiver is actor
# * sent_or_received_by(actor), the union of the former
# * related_by(relation), ties with this relation. Accepts relation, relation_name, integer, array
# * pending, ties whose relation grant other relations, like friendship requests.
# * inverse(tie), the inverse of tie
#
class Tie < ActiveRecord::Base
  # Facilitates relation assigment along with find_relation callback
  attr_accessor :relation_name

  # Avoids loops at create_inverse after save callback
  attr_accessor :_without_inverse
  attr_protected :_without_inverse

  belongs_to :sender,
             :class_name => "Actor",
             :include => SocialStream.actors
  belongs_to :receiver,
             :class_name => "Actor",
             :include => SocialStream.actors

  belongs_to :relation

  has_many :activities

  scope :recent, order("#{ quoted_table_name }.created_at DESC")

  scope :sent_by, lambda { |a|
    where(:sender_id => Actor_id(a))
  }

  scope :received_by, lambda { |a|
    where(:receiver_id => Actor_id(a))
  }

  scope :sent_or_received_by, lambda { |a|
    where(arel_table[:sender_id].eq(Actor_id(a)).
          or(arel_table[:receiver_id].eq(Actor_id(a))))

  }

  scope :related_by, lambda { |r|
    where(:relation_id => Relation(r))
  }

  scope :pending, includes(:relation) & Relation.request
  scope :active, includes(:relation) & Relation.active

  scope :inverse, lambda { |t|
    sent_by(t.receiver).
      received_by(t.sender).
      where(:relation_id => t.relation.inverse_id)
  }

  validates_presence_of :sender_id, :receiver_id, :relation_id

  before_validation :find_relation

  after_create :complete_weak_set, :create_inverse

  def sender_subject
    sender.try(:subject)
  end

  def receiver_subject
    receiver.try(:subject)
  end

  # The set of ties between sender and receiver
  #
  # Options::
  # * relations: Only ties with relations
  def relation_set(options = {})
    set = self.class.where(:sender_id => sender_id,
                           :receiver_id => receiver_id)

    if options.key?(:relations)
      set = 
        set.related_by self.class.Relation(options[:relations],
                                           :mode => relation.mode)
    end

    set
  end

  # The tie with relation r inside this relation_set
  def related(r)
    relation_set(:relations => r).first
  end

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

  # Before validation callback
  # Infers relation from its name and the type of the actors
  def find_relation
    if relation_name.present?
      self.relation = Relation.mode(sender_subject.class.to_s,
                                    receiver_subject.class.to_s).
                                    find_by_name(relation_name)
    end
  end

  # After create callback
  # Creates ties with a weaker relations in the strength hierarchy of this tie
  def complete_weak_set
    relation.weaker.each do |r|
      if relation_set(:relations => r).blank?
        t = relation_set.build :relation => r
        t._without_inverse = true
        t.save!
      end
    end
  end

  # After create callback
  # Creates a the inverse of this tie
  def create_inverse
    if !_without_inverse &&
       relation.inverse.present? &&
       Tie.inverse(self).blank?
      t = Tie.inverse(self).build
      t._without_inverse = true
      t.save!
    end
  end

  class << self
    def Actor_id(a)
      case a
      when Integer
        a
      when Actor
        a.id
      else
        a.actor.id
      end
    end

    # Normalize a relation for ActiveRecord query from relation_name, id or Array
    #
    # Options::
    # mode:: Relation mode
    def Relation(r, options = {})
      case r
      when Relation
        r
      when String
        case options[:mode]
        when Array
          Relation.mode(*options[:mode]).find_by_name(r)
        when ActiveRecord::Relation
          options[:mode].find_by_name(r)
        else
          raise "Must provide a mode when looking up relations from name: #{ options[:mode] }"
        end
      when Integer
        r
      when Array
        r.map{ |e| Relation(e, options) }
      else
        raise "Unable to normalize relation #{ r.inspect }"
      end
    end
  end
end
