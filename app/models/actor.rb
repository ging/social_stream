# An actor is a social entity. This includes individuals, but also groups, departments, organizations even nations or states. Actors are linked by ties.
class Actor < ActiveRecord::Base
  include SocialStream::Models::Supertype

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
