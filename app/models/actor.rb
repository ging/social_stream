# An {Actor} is a social entity. This includes individuals, but also groups, departments,
# organizations even nations or states.
#
# Actors are the nodes of a social network. Two actors are linked by a {Tie}. The
# type of a {tie} is a {Relation}. Each actor can define and customize their relations.
#
# = Actor subtypes
# An actor subtype is called a {SocialStream::Models::Subject Subject}.
# {SocialStream} provides 2 actor subtypes, {User} and {Group}, but the
# application developer can define as many actor subtypes as required.
# Actors subtypes are added to +config/initializers/social_stream.rb+
#
class Actor < ActiveRecord::Base
  @subtypes_name = :subject
  include SocialStream::Models::Supertype
  
  validates_presence_of :name, :subject_type
  
  acts_as_messageable
  acts_as_url :name, :url_attribute => :slug
  
  has_attached_file :logo,
                    :styles => { :tie => "30x30>",
                                 :actor => '35x35>',
                                 :profile => '94x94' },
                    :default_url => "/images/:attachment/:style/:subtype_class.png"
  
  has_one :profile, :dependent => :destroy
  
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
  
  after_create :create_profile
  
  class << self
    # Get actor's id from an object, if possible
    def normalize_id(a)
      case a
        when Array
        a.map{ |e| normalize_id(e) }
      else
        Actor.normalize(a).id
      end
    end
    # Get actor from object, if possible
    def normalize(a)
      case a
        when Actor
        a
        when Integer
        Actor.find a
        when Array
        a.map{ |e| Actor.normalize(e) }
      else
        begin
          a.actor
        rescue
          raise "Unable to normalize actor #{ a.inspect }"        
        end
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
    Relation.includes(:ties).merge(Tie.sent_by(self))
  end
  
  # A given relation defined and managed by this actor
  def relation(name)
    relations.find_by_name(name)
  end
  
  # All the actors this one has relation with
  #
  # Options:
  # * subject_type: Filter by the class of the subjects.
  # * direction: senders or receivers
  # * relations: Restrict the relations of considered ties
  # * include_self: False by default, don't include this actor as subject even they have ties with themselves.
  #
  def actors(options = {})
    subject_types   = Array(options[:subject_type] || self.class.subtypes)
    subject_classes = subject_types.map{ |s| s.to_s.classify }
    
    as = Actor.select("DISTINCT actors.*").
    where('actors.subject_type' => subject_classes).
    includes(subject_types)
    
    
    case options[:direction]
      when :senders
      as = as.joins(:sent_ties).merge(Tie.received_by(self))
      when :receivers
      as = as.joins(:received_ties).merge(Tie.sent_by(self))
    else
      raise "actors in both directions is not supported yet"
    end
    
    if options[:include_self].blank?
      as = as.where("actors.id != ?", self.id)
    end
    
    if options[:relations].present?
      as &= Tie.related_by(options[:relations])
    end
    
    as
  end
  
  # All the subject actors that send or receive at least one tie to this actor
  #
  # When passing a block, it will be evaluated for the actors query, allowing to add 
  # options before the mapping to subjects
  #
  # See actors for options
  def subjects(options = {})
    as = actors(options)
    
    if block_given?
      as = yield(as)
    end
    
    as.map(&:subject)
  end
  
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
    self.class.subtypes
    
    candidates_classes = candidates_types.map{ |t| t.to_s.classify.constantize }
    
    # Candidates are all the instance of "type" minus all the subjects
    # that are receiving any tie from this actor
    candidates = candidates_classes.inject([]) do |cs, klass|
      cs += klass.all - subjects(:subject_type => klass, :direction => :receivers)
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

  # The ties that allow attaching an activity to them. This method is used for caching
  def active_ties
    @active_ties ||= {}
  end

  # The ties that allow subject creating activities for this actor
  def active_ties_for(subject)
    active_ties[subject] ||=
      sent_ties_allowing(subject, 'create', 'activity')
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
