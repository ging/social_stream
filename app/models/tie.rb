# A link between two actors in a relation.
#
# The first Actor is the sender of the Tie. The second Actor is the receiver of the Tie.
#
# == Ties and Activities
# Activities are attached to ties. 
# * The sender of the tie is the target of the Activity. The wall-profile of an actor is
#   composed by the resources assigned to the ties in which the actor is the sender.
# * The receiver actor of the tie is the author of the Activity. It is the user that uploads 
#   a resource to the website or the social entity that originates the activity.
# * The Relation sets up the mode in which the Activity is shared. It sets the rules,
#    or permissions, by which actors have access to the Activity.
#
# == Authorization
# When an actor establishes a tie with other, she is granting a set of permissions to them
# (posting to her wall, reading her posts, etc..) The set of permissions granted are
# associated with the relation of the tie.
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
  attr_writer :relation_name

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

  has_many :tie_activities, :dependent => :destroy
  has_many :activities, :through => :tie_activities

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

  scope :inverse, lambda { |t|
    sent_by(t.receiver).
      received_by(t.sender).
      where(:relation_id => t.relation.inverse.try(:id))
  }

  validates_presence_of :sender_id, :receiver_id, :relation_id

  before_validation :find_relation

  after_create :complete_weak_set, :create_inverse

  def relation_name
    @relation_name || relation.try(:name)
  end

  def relation!
    relation ||
      find_relation
  end

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

  # The inverse tie
  def inverse
    Tie.inverse(self).first
  end

  def activity_receivers
    Array(inverse)
  end

  # = Access Control
  #
  # Access control enforcement in ties come from the permissions assigned to other ties through relations.
  # The access_set is the set of ties that grant some permission on a particular tie.
  #
  # Enforcing access control on activities and ties are a matter of finding its access set.
  # There are two approaches for this, checking the permissions on particular tie or finding all the ties
  # granted some permission.
  #
  # == Particular tie
  # ------------------        ------------------
  # | particular tie |--------|   access_set   |
  # |       t        |        |      ties      |
  # ------------------        ------------------
  #
  # Because t is given, the scopes are applied to the ties table
  # We get the set of ties that allow permission on t
  #
  # == Finding ties
  # ------------------  join  ------------------
  # |  finding ties  |--------|   access_set   |
  # |      ties      |        |     ties_as    |
  # ------------------        ------------------
  #
  # Because we want to find ties, an additional join table (ties_as) is needed for applying access set conditions
  # We get the set of ties that are allowing certain permission
  #

  scope :with_permissions, lambda { |action, object|
    joins(:relation => :permissions).
      where('permissions.action' => action).
      where('permissions.object' => object)
  }

  # Given a given permission (action, object), the access_set are the set of ties that grant that permission.
  scope :access_set, lambda { |tie, action, object|
    with_permissions(action, object).
      where(Permission.parameter_conditions(tie))
  }

  scope :allowing_set, lambda { |action, object|
    query = 
      select("DISTINCT ties.*").
        from("ties INNER JOIN relations ON relations.id = ties.relation_id, ties as ties_as INNER JOIN relations AS relations_as ON relations_as.id = ties_as.relation_id INNER JOIN relation_permissions ON relations_as.id = relation_permissions.relation_id INNER JOIN permissions ON permissions.id = relation_permissions.permission_id").
        where("permissions.action = ?", action).
        where("permissions.object = ?", object)

    conds = Permission.parameter_conditions
    # FIXME: Patch to support public activities
    if action == 'read' && object == 'activity'
      conds = sanitize_sql([ "( #{ conds } ) OR relations.name = ?", "public" ])
    end

    query.where(conds)
  }

  scope :allowing, lambda { |actor, action, object|
    allowing_set(action, object).
      where("ties_as.receiver_id" => Actor_id(actor))
  }

  def access_set(action, object)
    self.class.access_set(self, action, object)
  end

  def allowing(user, action, object)
    access_set(action, object).received_by(user)
  end

  def allow?(user, action, object)
    allowing(user, action, object).any?
  end

  private

  # Before validation callback
  # Infers relation from its name and the type of the actors
  def find_relation
    if relation_name.present? && relation_name != relation.try(:name)
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
