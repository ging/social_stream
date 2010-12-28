# An actor is a social entity. This includes individuals, but also groups, departments, organizations even nations or states. Actors are linked by ties.
class Actor < ActiveRecord::Base
  include SocialStream::Models::Supertype

  validates_presence_of :name, :subject_type

  acts_as_url :name, :url_attribute => :permalink

  has_attached_file :logo,
                    :styles => { :tie => "30x30>",
                                 :actor => '35x35>',
                                 :profile => '94x94' },
                    :default_url => "/images/:attachment/:style/:subtype_class.png"

  has_many :sent_ties,
           :class_name => "Tie",
           :foreign_key => 'sender_id',
           :dependent => :destroy

  has_many :received_ties,
           :class_name => "Tie",
           :foreign_key => 'receiver_id',
           :dependent => :destroy

  has_many :senders,
           :through => :received_ties,
           :uniq => true

  has_many :receivers,
           :through => :sent_ties,
           :uniq => true

  after_create :initialize_ties

  class << self
    # Get actor's id from an object, if possible
    def normalize_id(a)
      case a
      when Integer
        a
      when Array
        a.map{ |e| normalize_id(e) }
      when Actor
        a.id
      else
        a.actor.id
      end
    end
  end

  # The subject instance for this actor
  def subject
    subtype_instance ||
      activity_object.try(:object)
  end

  # All the ties sent or received by this actor
  def ties
    Tie.sent_or_received_by(self)
  end

  # Relations defined and managed by this actor
  def relations
    Relation.includes(:ties) & Tie.sent_by(self)
  end

  # A given relation defined and managed by this actor
  def relation(name)
    relations.find_by_name(name)
  end

  # All the subject actors that send at least one tie to this actor
  #
  # Options::
  # * subject_type: The class of the subjects. Defaults to actor's own subject type
  # * relations: Restrict the relations of considered ties
  # * include_self: False by default, don't include this actor as subject even they
  # have ties with themselves.
  def sender_subjects(options = {})
    # FIXME: DRY!
    options[:subject_type] ||= subject_type

    subject_class = options[:subject_type].to_s.classify.constantize

    cs = subject_class.
           select("DISTINCT #{ subject_class.quoted_table_name }.*").
           with_sent_ties &
           Tie.received_by(self)

    if options[:include_self].blank?
      cs = cs.where("#{ self.class.quoted_table_name }.id != ?", self.id)
    end

    if options[:relations].present?
      cs &=
        Tie.related_by(Tie.Relation(options[:relations]))
    end

    cs
  end

  # All the subject actors that receive at least one tie from this actor
  #
  # Options::
  # * subject_type: The class of the subjects. Defaults to actor's own subject type
  # * relations: Restrict the relations of considered ties
  # * include_self: False by default, don't include this actor as subject even they
  # have ties with themselves.
  def receiver_subjects(options = {})
    # FIXME: DRY!
    options[:subject_type] ||= subject_type

    subject_class = options[:subject_type].to_s.classify.constantize

    cs = subject_class.
           select("DISTINCT #{ subject_class.quoted_table_name }.*").
           with_received_ties &
           Tie.sent_by(self)

    if options[:include_self].blank?
      cs = cs.where("#{ self.class.quoted_table_name }.id != ?", self.id)
    end

    if options[:relations].present?
      cs &=
        Tie.related_by(Tie.Relation(options[:relations], :sender => sender))
    end

    cs
  end

  alias :contacts :receiver_subjects

  # This is an scaffold for a recomendations engine
  #

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
    candidates_types =
      options[:type].present? ?
        Array(options[:type]) :
        SocialStream.actors

    candidates_classes = candidates_types.map{ |t| t.to_s.classify.constantize }
    
    # Candidates are all the instance of "type" minus all the subjects
    # that are receiving any tie from this actor
    candidates = candidates_classes.inject([]) do |cs, klass|
      cs += klass.all - receiver_subjects(:subject_type => klass)
      cs -= Array(subject) if subject.is_a?(klass)
      cs
    end

    candidate = candidates[rand(candidates.size)]

    return nil unless candidate.present?

    # Building ties with sent_ties catches them and excludes them from pending ties.
    # An useful side effect for excluding this ones from pending, but can be weird!
    # Maybe we must use:
    # Tie.sent_by(self).build :receiver_id => candidate.actor.id
    sent_ties.build :receiver_id => candidate.actor.id
  end

  # Set of ties sent by this actor received by a
  def ties_to(a)
    sent_ties.received_by(a)
  end

  # All the ties this actor has with subject that support permission
  def sent_ties_allowing(subject, action, objective)
    return [] if subject.blank?

    sent_ties.allowing(subject, action, objective)
  end

  def pending_ties
    @pending_ties ||=
      received_ties.where('ties.sender_id NOT IN (?)', sent_ties.map(&:receiver_id).uniq).map(&:sender_id).uniq.
        map{ |i| Tie.new :sender => self,
                         :receiver_id => i }
  end

  # The set of activities in the wall of this actor, includes all the activities
  # from the ties the actor has access to
  #
  def home_wall
    Activity.home_wall ties
  end

  # The set of activities in the wall profile of this actor, includes the activities
  # from the ties of this actor that can be read by user
  #
  def profile_wall(user)
    # FIXME: show public activities
    return [] if user.blank?

    Activity.profile_wall ties.allowing(user, 'read', 'activity')
  end

  private

  def initialize_ties
    ::SocialStream::Relations.create(subject_type).each do |r|
      sent_ties.create! :receiver => self,
                        :relation => r
    end
  end
end

