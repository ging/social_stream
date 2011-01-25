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
# == Scopes
# There are several scopes defined:
# * sent_by(actor), ties whose sender is actor
# * received_by(actor), ties whose receiver is actor
# * sent_or_received_by(actor), the union of the former
# * related_by(relation), ties with this relation. Accepts relation, relation_name, integer, array
# * replied, ties having at least another tie in the other way, a tie from a to b is replied if there is a tie from b to a
#
class Tie < ActiveRecord::Base
  attr_accessor :message

  # Facilitates relation assigment along with find_relation callback
  attr_writer :relation_name

  belongs_to :sender,
             :class_name => "Actor",
             :include => SocialStream.subjects
  belongs_to :receiver,
             :class_name => "Actor",
             :include => SocialStream.subjects

  belongs_to :relation

  has_many :tie_activities, :dependent => :destroy
  has_many :activities, :through => :tie_activities

  scope :recent, order("#{ quoted_table_name }.created_at DESC")

  scope :sent_by, lambda { |a|
    where(:sender_id => Actor.normalize_id(a))
  }

  scope :received_by, lambda { |a|
    where(:receiver_id => Actor.normalize_id(a))
  }

  scope :sent_or_received_by, lambda { |a|
    where(arel_table[:sender_id].eq(Actor.normalize_id(a)).
          or(arel_table[:receiver_id].eq(Actor.normalize_id(a))))

  }

  scope :related_by, lambda { |r|
    where(:relation_id => Relation.normalize_id(r))
  }

  scope :replied, lambda {
    select("DISTINCT ties.*").
      from("ties, ties as ties_2").
      where("ties.sender_id = ties_2.receiver_id AND ties.receiver_id = ties_2.sender_id")
  }

  scope :following, lambda { |a|
    where(:receiver_id => Actor.normalize_id(a)).
      joins(:relation => :permissions) & Permission.follow
  }

  validates_presence_of :sender_id, :receiver_id, :relation_id

  before_validation :find_relation

  after_create :complete_weak_set

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

  # Does this tie have the same sender and receiver?
  def reflexive?
    sender_id == receiver_id
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
        set.related_by Relation.normalize_id(options[:relations],
                                             :sender => sender)
    end

    set
  end

  # The tie with relation r inside this relation_set
  def related(r)
    relation_set(:relations => r).first
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
      where("ties_as.receiver_id" => Actor.normalize_id(actor))
  }

  # The set of ties that permit this tie allow to allow action on object
  def access_set(action, object)
    self.class.access_set(self, action, object)
  end

  # The set of ties allowing user to perform action on object
  def allowing(user, action, object)
    access_set(action, object).received_by(user)
  end

  # Does this tie allows user to perform action on object?
  def allows?(user, action, object)
    # FIXME: Patch to support public activities
    return true if relation.name == 'public' && action == 'read' && object == 'activity'

    allowing(user, action, object).any?
  end

  private

  # Before validation callback
  # Infers relation from its name and the type of the actors
  def find_relation
    if relation_name.present? &&
      relation_name != relation.try(:name) &&
      sender.present?
      self.relation = sender.relation(relation_name)
    end
  end

  # After create callback
  # Creates ties with a weaker relations in the strength hierarchy of this tie
  def complete_weak_set
    return if reflexive?

    relation.weaker.each do |r|
      if relation_set(:relations => r).blank?
        t = relation_set.build :relation => r
        t.save!
      end
    end
  end
end
