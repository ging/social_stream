# A relation defines a type of {Tie tie}. Relations are affective (friendship, liking, 
# respect), formal or biological (authority, kinship), transfer of material 
# resources (transactions, lending and borrowing), messages or conversations, 
# physical connection and affiliation to same organizations.
#
# = Default relations
#
# When a new {SocialStream::Models::Subject subject} is created, a initial set
# of relations is created for him. Afterwards, the {SocialStream::Models::Subject subject}
# can customize them and adapt them to his own preferences.
#
# Default relations are defined at config/relations.yml
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
class Relation < ActiveRecord::Base
  # The actor this relation belongs to
  attr_accessor :actor

  # Default relations are defined in this configuration file
  CONFIG = File.join(::Rails.root, 'config', 'relations.yml')

  acts_as_nested_set

  scope :mode, lambda { |st, rt|
    where(:sender_type => st, :receiver_type => rt)
  }

  has_many :relation_permissions, :dependent => :destroy
  has_many :permissions, :through => :relation_permissions

  has_many :ties, :dependent => :destroy

  before_create :initialize_sender_type
  after_create  :initialize_ties

  class << self
    # Relations configuration
    def config
      @config ||= YAML.load_file(CONFIG)
    end

    def defaults_for(actor)
      cfg_rels = config[actor.subject_type.underscore]

      if cfg_rels.nil?
        raise "Undefined relations for subject type #{ actor.subject_type }. Please, add an entry to #{ CONFIG }"
      end

      rels = {}

      cfg_rels.each_pair do |name, cfg_rel|
        rels[name] =
          Relation.create! :actor         => actor,
                           :receiver_type => cfg_rel['receiver_type'],
                           :name =>          cfg_rel['name']

        if (ps = cfg_rel['permissions']).present?
          ps.each do |p| 
            rels[name].permissions << 
              Permission.find_or_create_by_action_and_object_and_function(*p)
          end 
        end
      end

      # Parent, relations must be set after creation
      # FIXME: Can fix with ruby 1.9 and ordered hashes
      cfg_rels.each_pair do |name, cfg_rel|
        rels[name].update_attribute(:parent, rels[cfg_rel['parent']]) if cfg_rel['parent'].present?
      end

      rels.values
    end

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
          options[:sender].relation(r)
        else
          raise "Must provide a sender when looking up relations from name: #{ options[:sender] }"
        end
      when Integer
        Relation.find r
      when Array
        r.map{ |e| Relation.normalize(e, options) }
      else
        raise "Unable to normalize relation #{ r.inspect }"
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

    # A relation in the top of a strength hierarchy
    def strongest
      root
    end
  end

  # Other relations below in the same hierarchy that this relation
  def weaker
    descendants
  end

  # Relations below or at the same level of this relation
  def weaker_or_equal
    self_and_descendants
  end

  # Other relations above in the same hierarchy that this relation
  def stronger
    ancestors
  end

  # Relations above or at the same level of this relation
  def stronger_or_equal
    self_and_ancestors
  end

  # Relation class scoped in the same mode that this relation
  def mode
    Relation.mode(sender_type, receiver_type)
  end

  private

  # Before create callback
  def initialize_sender_type
    return if actor.blank?

    self.sender_type = actor.subject_type
  end

  # Create reflexive ties for this actor
  def initialize_ties
    return if actor.blank?

    ties.create! :sender   => actor,
                 :receiver => actor
  end
end
