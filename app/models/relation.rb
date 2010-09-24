# A Relation defines a type of Tie. Relations are affective (friendship, liking, 
# respect), formal or biological (authority, kinship), transfer of material 
# resources (transactions, lending and borrowing), messages or conversations, 
# physical connection and affiliation to same organizations.
#
# == Strength hierarchies
# Relations are arranged in strength hierarchies, denoting that some ties between
# two actors are stronger than others.
# When a strong tie is established, ties with weaker relations are establised as well
#
# == Inverse relations
# A Relation can have its inverse. When a tie is established, an inverse tie will be
# established if an inverse relation exists. An example is a relation of friendship,
# whose inverse relation is itself. When A is friend of B, the inverse tie B is friend of A
# is establised as well.
#
#
class Relation < ActiveRecord::Base
  has_ancestry

  belongs_to  :inverse,
              :class_name => "Relation"

  has_many :relation_permissions, :dependent => :destroy
  has_many :permissions, :through => :relation_permissions


  scope :mode, lambda { |st, rt|
    where(:sender_type => st, :receiver_type => rt)
  }

  class << self
    # A relation in the top of a strength hierarchy
    def strongest
      roots.first
    end
  end

  # Other relations below in the same hierarchy that this relation
  def weaker
    descendants
  end

  # Relations below or at the same level of this relation
  def weaker_or_equal
    Array(self) + descendants
  end

  # Other relations above in the same hierarchy that this relation
  def stronger
    ancestors
  end

  # Relations above or at the same level of this relation
  def stronger_or_equal
    ancestors + Array(self)
  end

  # Relation class scoped in the same mode that this relation
  def mode
    Relation.mode(sender_type, receiver_type)
  end
end
