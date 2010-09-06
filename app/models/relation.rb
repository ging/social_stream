class Relation < ActiveRecord::Base
  Available = []

  has_many :relation_permissions
  has_many :permissions, :through => :relation_permissions

  class << self
    def [] name
      find_by_name name
    end

    def strength_index(relation)
      r = ( relation.is_a?(Relation) ? relation.name : relation )

      self::Available.index(r)
    end

    def weaker_set(relation)
      strength_index(relation) ?
        self::Available[strength_index(relation) + 1 .. self::Available.size].
          map{ |n| self[n] } :
        Array.new
    end

    def stronger_set(relation)
      strength_index(relation) ?
        self::Available[0 ... strength_index(relation)].
          map{ |n| self[n] } :
        Array.new
    end


    def strongest
      self[self::Available.first]
    end

    def weakest
      self[self::Available.last]
    end

    def filter_with_permission(set, permission)
      includes(:permissions).where(:id => set).where('permissions.object' => permission)
    end
  end

  def strength_index
    self.class.strength_index(self)
  end

  def weaker
    self.class.weaker_set(self)
  end

  def weaker_or_equal
    Array(self) + weaker
  end

  def stronger
    self.class.stronger_set(self)
  end

  def stronger_or_equal
    stronger + Array(self)
  end
end
