class Sphere < ActiveRecord::Base
  belongs_to :actor
  
  has_many :customs, :class_name => "Relation::Custom"

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :actor_id

end
