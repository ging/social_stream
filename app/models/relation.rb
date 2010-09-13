# A Relation defines a type of Tie. Relations are affective (friendship, liking, 
# respect), formal or biological (authority, kinship), transfer of material 
# resources (transactions, lending and borrowing), messages or conversations, 
# physical connection and affiliation to same organizations.
#
class Relation < ActiveRecord::Base
  has_many :relation_permissions
  has_many :permissions, :through => :relation_permissions

  has_ancestry

  class << self
    def [] mode, name
      find_by_mode_and_name mode, name
    end

    def strongest
      roots.first
    end
  end

  def weaker
    descendants
  end

  def weaker_or_equal
    Array(self) + descendants
  end

  def stronger
    ancestors
  end

  def stronger_or_equal
    ancestors + Array(self)
  end
end
