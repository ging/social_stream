# An actor is a social entity. This includes individuals, but also groups, departments, organizations even nations or states. Actors are linked by ties.
class Actor < ActiveRecord::Base
  include SocialStream::Models::Supertype

  validates_presence_of :name, :subject_type

  acts_as_url :name, :url_attribute => :permalink

  has_attached_file :logo,
                    :styles => { :small => "30x30" },
                    :default_url => "/images/:attachment/:style/:subtype_class.png"

  has_many :sent_ties,
           :class_name => "Tie",
           :foreign_key => 'sender_id',
           :dependent => :destroy

  has_many :senders,
           :through => :received_ties,
           :uniq => true

  has_many :received_ties,
           :class_name => "Tie",
           :foreign_key => 'receiver_id',
           :dependent => :destroy

  has_many :receivers,
           :through => :sent_ties,
           :uniq => true

  # The subject instance for this actor
  def subject
    subtype_instance ||
      activity_object.try(:object)
  end

  # All the ties sent or received by this actor
  def ties
    Tie.sent_or_received_by(self)
  end

  # All the subject actors of class subject_type that send at least one tie
  # to this actor
  #
  # Options::
  # * relations: Restrict the relations of considered ties
  # * include_self: False by default, don't include this actor as subject even they
  # have ties with themselves.
  def sender_subjects(subject_type, options = {})
    # FIXME: DRY!
    subject_class = subject_type.to_s.classify.constantize

    cs = subject_class.
           select("DISTINCT #{ subject_class.quoted_table_name }.*").
           with_sent_ties &
           Tie.received_by(self)

    if options[:include_self].blank?
      cs = cs.where("#{ self.class.quoted_table_name }.id != ?", self.id)
    end

    if options[:relations].present?
      cs &=
        Tie.related_by(Tie.Relation(options[:relations], :mode => [ subject_class, self.subject.class ]))
    end

    cs
  end

  # All the subject actors of class subject_type that receive at least one tie
  # from this actor
  #
  # Options::
  # * relations: Restrict the relations of considered ties
  # * include_self: False by default, don't include this actor as subject even they
  # have ties with themselves.
  def receiver_subjects(subject_type, options = {})
    # FIXME: DRY!
    subject_class = subject_type.to_s.classify.constantize

    cs = subject_class.
           select("DISTINCT #{ subject_class.quoted_table_name }.*").
           with_received_ties &
           Tie.sent_by(self)

    if options[:include_self].blank?
      cs = cs.where("#{ self.class.quoted_table_name }.id != ?", self.id)
    end

    if options[:relations].present?
      cs &=
        Tie.related_by(Tie.Relation(options[:relations], :mode => [ subject.class, subject_class ]))
    end

    cs
  end

  # This is an scaffold for a recomendations engine
  #
  SuggestedRelations = {
    'User'  => 'friend_request',
    'Group' => 'follower'
  }

  # Make n suggestions
  # TODO: make more
  def suggestions(n)
    n.times.map{ |m| suggestion }
  end

  # By now, it returns a tie suggesting a relation from SuggestedRelations
  # to another subject without any current relation
  #
  # Options::
  # * type: the class of the recommended subject
  #
  # @return [Tie]
  def suggestion(options = {})
    candidates_types = options[:type].present? ?
      Array(options[:type].to_s.classify) :
      SuggestedRelations.keys

    candidates_classes = candidates_types.map(&:constantize)
    
    # Candidates are all the instance of "type" minus all the subjects
    # that are receiving any tie from this actor
    candidates = candidates_classes.inject([]) do |cs, klass|
      cs += klass.all - receiver_subjects(klass)
      cs -= Array(subject) if subject.is_a?(klass)
      cs
    end

    candidate = candidates[rand(candidates.size)]

    return nil unless candidate.present?

    sent_ties.build :receiver_id => candidate.id,
                    :relation => Relation.mode(subject_type, candidate.class).find_by_name(SuggestedRelations[candidate.class.to_s])
  end

  # All the ties this actor has with subject that support activities
  def active_ties_to(subject)
    sent_ties.received_by(subject).active
  end

  def pending_ties
    #TODO: optimize by SQL
    @pending_ties ||=
      received_ties.pending.
        select{ |t| ! receivers.include?(t.sender) }.
        map{ |u| Tie.new :sender_id => u.receiver_id,
                         :receiver_id => u.sender_id,
                         :relation_id => u.relation.granted_id
        }
  end

  # The set of activities in the wall of this actor, includes all the activities
  # from the ties the actor has access to
  #
  # TODO: ties, authorization
  def wall
    Activity.wall ties
  end

  # The set of activities in the wall profile of this actor, includes the activities
  # from the ties of this actor
  # TODO: authorization
  def wall_profile
    Activity.wall ties
  end
end

