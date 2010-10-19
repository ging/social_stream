# An actor is a social entity. This includes individuals, but also groups, departments, organizations even nations or states. Actors are linked by ties.
class Actor < ActiveRecord::Base
  include SocialStream::Models::Supertype

  has_many :sent_ties,
           :class_name => "Tie",
           :foreign_key => 'sender_id',
           :dependent => :destroy

  has_many :received_ties,
           :class_name => "Tie",
           :foreign_key => 'receiver_id',
           :dependent => :destroy

  # The subject instance for this actor
  def subject
    subtype_instance ||
      activity_object.try(:object)
  end

  # All the ties sent or received by this actor
  def ties
    Tie.sent_or_received_by(self)
  end

  # All the subject actors of class type that have at least one tie
  # with this actor
  #
  # Options::
  # * relations: Restrict the relations of considered ties
  def contacts(type, options = {})
    type_class = type.to_s.classify.constantize

    cs = type_class.
           select("DISTINCT #{ type_class.quoted_table_name }.*").
           with_received_ties &
           Tie.sent_by(self)

    if options[:relations].present?
      cs &=
        Tie.related_by(Tie.Relation(options[:relations], :mode => [ subject.class, type_class ]))
    end

    cs
  end

  # This is an scaffold for a recomendations engine
  #
  # By now, it returns another actor without any current relation
  def suggestion(type = subject.class)
    candidates = type.to_s.classify.constantize.all - contacts(type)

    candidates[rand(candidates.size)]
  end

  # The set of activities in the wall of this actor
  # TODO: authorization
  def wall
    Activity.wall ties
  end
end

