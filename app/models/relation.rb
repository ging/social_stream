class Relation < ActiveRecord::Base
  has_many :relation_permissions
  has_many :permissions, :through => :relation_permissions

  has_ancestry

  # FIXME: This model can be preloaded before table exists. ancestry bug?
  if table_exists?
    scope :strongest, roots.first
  end

  class << self
    def [] mode, name
      find_by_mode_and_name mode, name
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
