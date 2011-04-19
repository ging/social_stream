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
  
  delegate :tag_list, :tag_list=, :tagged_with, :tag_counts, :to => :activity_object
  
  validates_presence_of :name, :subject_type
  
  acts_as_messageable
  
  acts_as_url :name, :url_attribute => :slug
  
  has_one :profile, :dependent => :destroy

  has_many :avatars,
           :validate => true,
           :autosave => true
  		  
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

  has_many :spheres

  has_many :relations, :through => :spheres

  scope :alphabetic, order('actors.name')

  scope :letter, lambda { |param|
    if param.present?
      where('actors.name LIKE ?', "#{ param }%")
    end
  }

  scope :search, lambda { |param|
    if param.present?
      where('actors.name LIKE ?', "%#{ param }%")
    end
  }
  
  scope :tagged_with, lambda { |param|
    if param.present?
      joins(:activity_object).merge(ActivityObject.tagged_with(param))
    end
  }

  scope :distinct_initials, select('DISTINCT SUBSTR(actors.name,1,1) as initial').order("initial ASC")

  scope :contacted_to, lambda { |a|
    joins(:sent_ties).merge(Tie.received_by(a))
  }

  scope :contacted_from, lambda { |a|
    joins(:received_ties).merge(Tie.sent_by(a))
  }
 
  after_create :create_initial_relations
  
  after_create :create_profile
  
  class << self
    # Get actor's id from an object, if possible
    def normalize_id(a)
      case a
      when Integer
        a
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

    def find_by_webfinger!(link)
      link =~ /(acct:)?(.*)@/

      find_by_slug! $2
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
  
  # A given relation defined and managed by this actor
  def relation(name)
    relations.find_by_name(name)
  end

  # The {Relation::Public} for this {Actor} 
  def relation_public
    Relation::Public.of(self)
  end
  
  # All the {Actor actors} this one has relation with
  #
  # Options:
  # * type: Filter by the class of the contacts.
  # * direction: sent or received
  # * relations: Restrict the relations of considered ties
  # * include_self: False by default, don't include this actor as subject even they have ties with themselves.
  #
  def contact_actors(options = {})
    subject_types   = Array(options[:type] || self.class.subtypes)
    subject_classes = subject_types.map{ |s| s.to_s.classify }
    
    as = Actor.select("DISTINCT actors.*").
    where('actors.subject_type' => subject_classes).
    includes(subject_types)
    
    
    case options[:direction]
      when :sent
        as = as.contacted_from(self)
      when :received
        as = as.contacted_to(self)
    else
      raise "contact actors in both directions are not supported yet"
    end
    
    if options[:include_self].blank?
      as = as.where("actors.id != ?", self.id)
    end
    
    if options[:relations].present?
      as = as.merge(Tie.related_by(options[:relations]))
    end
    
    as
  end
  
  # All the {SocialStream::Models::Subject subjects} that send or receive at least one {Tie} to this {Actor}
  #
  # When passing a block, it will be evaluated for building the actors query, allowing to add 
  # options before the mapping to subjects
  #
  # See #contact_actors for options
  def contacts(options = {})
    as = contact_actors(options)
    
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
      cs += klass.all - contacts(:type => klass, :direction => :sent)
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

  # Get the first of the ties created to a, or create a new one with the {Relation::Public}
  def ties_to!(a)
    ties_to(a).present? ?
      ties_to(a) :
      Array(sent_ties.create!(:receiver => a,
                              :relation => relation_public))
  end
  
  def ties_to?(a)
    ties_to(a).present?
  end

  # The sent {Tie ties} by this {Actor} that grant subject the permission to perform action on object
  def allow(subject, action, object = nil)
    return [] if subject.blank?

    sent_ties.allowing(subject, action, object)
  end

  # Does this {Actor} have any {Tie} to subject that grants her the permission of performing action on object
  def allow?(subject, action, object = nil)
    allow(subject, action, object).any?
  end
  
  # Can this actor be represented by subject. Does she has permissions for it?
  def represented_by?(subject)
    return false if subject.blank?

    self.class.normalize(subject) == self ||
      allow?(subject, 'represent')
  end

  # The ties that allow attaching an activity to them. This method is used for caching
  def active_ties
    @active_ties ||= {}
  end

  # This {Actor} #allow s subject to create activities and subject has at least one tie to subject
  def activity_ties_for(subject)
    active_ties[subject] ||=
      ( allow?(subject, 'create', 'activity') ?
        subject.ties_to!(self) :
        [] )
  end

  # Is there any {Tie} for subject to create an activity to this {Actor} ?
  def activity_ties_for?(subject)
    activity_ties_for(subject).any?
  end

  def pending_ties
    @pending_ties ||=
    received_ties.where('ties.sender_id NOT IN (?)', sent_ties.map(&:receiver_id).uniq).map(&:sender_id).uniq.
    map{ |i| Tie.new :sender => self,
                         :receiver_id => i }
  end
  
  # The set of {Activity activities} in the wall of this {Actor}.
  #
  # There are two types of walls:
  # home:: includes all the {Activity activities} from this {Actor} and their followed {Actor actors}
  #             See {Permission permissions} for more information on the following support
  # profile:: The set of activities in the wall profile of this {Actor}, it includes only the
  #           activities from the ties of this actor that can be read by the subject
  #
  # Options:
  # :for:: the subject that is accessing the wall
  # :relation:: show only activities that are attached at this relation level. For example,
  #             the wall for members of the group.
  #             
  def wall(type, options = {})
    ts = ties

    if type == :profile
      return ties.public_relation if options[:for].blank?

      ts = ts.allowing(options[:for], 'read', 'activity')
    end

    if options[:relation].present?
      ts = ts.related_by(Relation.normalize(options[:relation], :sender => self))
    end

    Activity.wall type, ts
  end
  
  def logo
    avatar!.logo
  end

  def avatar!
    avatars.active.first || avatars.build
  end
  
  # The 'like' qualifications emmited to this actor
  def likes
    Activity.joins(:activity_verb).where('activity_verbs.name' => "like").
             joins(:activity_objects).where('activity_objects.id' => activity_object_id)
  end
  
  def liked_by(subject) #:nodoc:
    likes.joins(:ties).where('tie_activities.original' => true).merge(Tie.sent_by(subject))
  end
  
  # Does subject like this {Actor}?
  def liked_by?(subject)
    liked_by(subject).present?
  end
  
  # Build a new activity where subject like this
  def new_like(subject)
    a = Activity.new :verb => "like",
                     :_tie => subject.ties_to(self).first
    
    a.activity_objects << activity_object           
                    
    a             
  end
  
  private
  
  # After create callback
  def create_initial_relations
    Relation::Custom.defaults_for(self)
    Relation::Public.default_for(self)
  end
end
