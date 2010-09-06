class Actor < ActiveRecord::Base
  include ActiveRecord::Supertype

  has_many :ties,
           :foreign_key => 'sender_id',
           :include => [ :receiver, :relation ],
           :dependent => :destroy

  # The subject instance for this actor
  def subject
    subtype_instance ||
      activity_object.try(:object)
  end
end
