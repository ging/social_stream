# A relation defines a type of {Tie tie}. Relations are affective (friendship, liking, 
# respect), formal or biological (authority, kinship), transfer of material 
# resources (transactions, lending and borrowing), messages or conversations, 
# physical connection and affiliation to same organizations.
#
# = Strength hierarchies
#
# Relations are arranged in strength hierarchies, denoting that some ties between
# two actors are stronger than others. For example, a "friend" relation is stronger than 
# an "acquaintance" relation.
#
# When a strong tie is established, ties with weaker relations are establised as well
#
# = Permissions
#
# {SocialStream::Models::Subject Subjects} assign {Permission permissions} to relations.
# This way, when establishing {Tie ties}, they are granting permissions to their contacts.
#
# See the documentation of {Permission} for more details on permission definition.
#
# = {Activity Activities} and {Relation relations}
# Each {Activity} can be attached to one or more {Relation relations}.
# The {Relation} sets up the mode in which the {Activity} is shared.
# It sets the {Audience} that has access to it, and the {Permission Permissions} that rule that access.
#
class Relation < ActiveRecord::Base
  Positive = %w{ custom public }
  Negative = %w{ reject }

  belongs_to :actor

  has_many :relation_permissions, :dependent => :destroy
  has_many :permissions, :through => :relation_permissions

  has_many :ties, :dependent => :destroy
  has_many :contacts, :through => :ties

  has_many :audiences, :dependent => :destroy
  has_many :activities, :through => :audiences

  validates_presence_of :actor_id

  scope :actor, lambda { |a|
    where(:actor_id => Actor.normalize_id(a))
  }

  scope :mode, lambda { |st, rt|
    where(:sender_type => st, :receiver_type => rt)
  }

  before_create :initialize_sender_type

  class << self
    # Get relation from object, if possible
    #
    # Options::
    # sender:: The sender of the tie
    def normalize(r, options = {})
      case r
      when Relation
        r
      when String
        if options[:sender]
          options[:sender].relation_custom(r)
        else
          raise "Must provide a sender when looking up relations from name: #{ options[:sender] }"
        end
      when Integer
        Relation.find r
      when Array
        r.map{ |e| Relation.normalize(e, options) }
      else
        raise "Unable to normalize relation #{ r.class }: #{ r.inspect }"
      end
    end

    def normalize_id(r, options = {})
      case r
      when Integer
        r
      when Array
        r.map{ |e| Relation.normalize_id(e, options) }
      else
        normalize(r, options).id
      end
    end

    # Positive relation names: [ 'Relation::Custom', 'Relation::Public' ]
    def positive_names
      Positive.map{ |r| "Relation::#{ r.classify }" }
    end

    # Negative relations: [ 'Relation::Reject' ]
    def negative_names
      Negative.map{ |r| "Relation::#{ r.classify }" }
    end

    # All the relations that allow subject to perform action
    #
    # Options:
    #   in:: Limit possible relations to a set
    #   public_relations:: include also {Relation::Public} whose activities can always be read
    def allow(subject, action, object, options = {})
      q = 
        select("DISTINCT relations.*").
        joins(:contacts).
        joins(:permissions)

      conds =
        Permission.arel_table[:action].eq(action).and(Permission.arel_table[:object].eq(object))

      # Relation::Public permissions cannot be customized yet
      if action == 'read' && object == 'activity' && (options[:public].nil? || options[:public])
        conds = conds.or(Relation.arel_table[:type].eq('Relation::Public'))
      end

      # Add in condition
      if ! options[:in].nil?
        conds = conds.and(Relation.arel_table[:id].in(Relation.normalize_id(Array(options[:in]))))
      end

      # subject conditions
      conds = conds.and(Contact.arel_table[:receiver_id].eq(Actor.normalize_id(subject)))

      q.where(conds)
    end

    def allow?(*args)
      allow(*args).to_a.any?
    end
  end

  # Relation class scoped in the same mode that this relation
  def mode
    Relation.mode(sender_type, receiver_type)
  end

  # Is this {Relation} a Positive one?
  def positive?
    self.class.positive_names.include?(self.class.to_s)
  end

  private

  # Before create callback
  def initialize_sender_type
    return if actor.blank?

    self.sender_type = actor.subject_type
  end
end

