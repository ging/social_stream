class Room < ActiveRecord::Base
  belongs_to :actor

  has_many :events

  validates_presence_of :actor_id, :name
  validates_uniqueness_of :name, :scope => :actor_id
end
