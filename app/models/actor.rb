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
  include SocialStream::Models::Object
  
  delegate :tag_list, :tag_list=, :tagged_with, :tag_counts, :to => :activity_object
  
  validates_presence_of :name, :subject_type
  
  acts_as_messageable
  
  acts_as_url :name, :url_attribute => :slug
  
  has_one :profile, :dependent => :destroy

  has_many :avatars,
           :validate => true,
           :autosave => true
  		  
  has_many :sent_contacts,
           :class_name  => 'Contact',
           :foreign_key => 'sender_id',
           :dependent   => :destroy

  has_many :received_contacts,
           :class_name  => 'Contact',
           :foreign_key => 'receiver_id',
           :dependent   => :destroy

  has_many :sent_ties,
           :through => :sent_contacts,
           :source  => :ties
  
  has_many :received_ties,
           :through => :received_contacts,
           :source  => :ties
  
  has_many :senders,
           :through => :received_contacts,
           :uniq => true
  
  has_many :receivers,
           :through => :sent_contacts,
           :uniq => true

  has_many :relations
  has_many :spheres

  has_many :relation_customs,
           :through => :spheres, 
           :source  => :customs

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
    joins(:sent_contacts).merge(Contact.active.received_by(a))
  }

  scope :contacted_from, lambda { |a|
    joins(:received_contacts).merge(Contact.active.sent_by(a))
  }

  scope :followed_by, lambda { |a|
    select("DISTINCT actors.*").
      joins(:received_ties => { :relation => :permissions }).
      merge(Contact.sent_by(a)).
      merge(Permission.follow)
  }

  after_create :create_initial_relations
  
  after_create :save_or_create_profile
  
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

  # A given relation defined and managed by this actor
  def relation_custom(name)
    relation_customs.find_by_name(name)
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
      as = as.joins(:ties).merge(Tie.related_by(options[:relations]))
    end
    
    as
  end
  
  # All the {SocialStream::Models::Subject subjects} that send or receive at least one {Tie} to this {Actor}
  #
  # When passing a block, it will be evaluated for building the actors query, allowing to add 
  # options before the mapping to subjects
  #
  # See #contact_actors for options
  def contact_subjects(options = {})
    as = contact_actors(options)
    
    if block_given?
      as = yield(as)
    end
    
    as.map(&:subject)
  end

  # Return a contact to subject. Create it if it does not exist
  def contact_to!(subject)
    Contact.find_or_create_by_sender_id_and_receiver_id id, Actor.normalize_id(subject)
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
  # @return [Contact]
  def suggestion(options = {})
    candidates_types =
      ( options[:type].present? ?
          Array(options[:type]) :
          self.class.subtypes )
    
    candidates_classes = candidates_types.map{ |t| t.to_s.classify.constantize }
    
    # Candidates are all the instance of "type" minus all the subjects
    # that are receiving any tie from this actor
    candidates = candidates_classes.inject([]) do |cs, klass|
      cs += klass.all - contact_subjects(:type => klass.to_s.underscore, :direction => :sent)
      cs -= Array(subject) if subject.is_a?(klass)
      cs
    end
    
    candidate = candidates[rand(candidates.size)]
    
    return nil unless candidate.present?
    
    Contact.new :sender => self, :receiver => candidate.actor
  end
  
  # Set of ties sent by this actor received by subject
  def ties_to(subject)
    sent_ties.merge(Contact.received_by(subject))
  end

  def ties_to?(subject)
    ties_to(subject).present?
  end

 
  def ties_to?(a)
    ties_to(a).present?
  end

  # Can this actor be represented by subject. Does she has permissions for it?
  def represented_by?(subject)
    return false if subject.blank?

    self.class.normalize(subject) == self ||
      sent_ties.
        merge(Contact.received_by(subject)).
        joins(:relation => :permissions).
        merge(Permission.represent).
        any?
  end

  # The relations that allow attaching an activity to them. This method is used for caching
  def active_relations
    @active_relations ||= { :sender => {}, :receiver => {} }
  end

  # An {Activity} can be shared with multiple {audicences Audience}, which corresponds to a {Relation}.
  #
  # This method returns all the {relations Relation} that this actor can use to broadcast an Activity
  #
  # Options:
  # from:: limit the relations to one side, from the :sender or the :receiver of the activity
  #
  def activity_relations(subject, options = {})
    return relations if Actor.normalize(subject) == self

    case options[:from]
    when :sender
      sender_activity_relations(subject)
    when :receiver
      receiver_activity_relations(subject)
    else
      sender_activity_relations(subject) +
        receiver_activity_relations(subject)
    end
  end

  # Are there any activity_relations present?
  def activity_relations?(*args)
    activity_relations(*args).any?
  end

  # Relations from this actor that can be read by subject
  def sender_activity_relations(subject)
    active_relations[:sender][subject] ||=
      Relation.allow(subject, 'read', 'activity', :owner => self)
  end

  def receiver_activity_relations(subject)
    active_relations[:receiver][subject] ||=
      Relation.allow(self, 'create', 'activity', :owner => subject)
  end

  # Builds a hash of options their spheres as keys
  def grouped_activity_relations(subject)
    rels = activity_relations(subject)

    spheres =
      rels.map{ |r| r.respond_to?(:sphere) ? r.sphere : I18n.t('relation_public.name') }.uniq

    spheres.sort!{ |x, y|
      case x
      when Sphere
        case y
        when Sphere
          x.id <=> y.id
        else
          -1
        end
      else
        1
      end
    }

    spheres.map{ |s|
      case s
      when Sphere
        [ s.name, rels.select{ |r| r.respond_to?(:sphere) && r.sphere == s }.sort.map{ |u| [ u.name, u.id ] } ]
      else
        [ s, rels.select{ |r| r.is_a?(Relation::Public) }.map{ |u| [ u.name, u.id ] } ]
      end
    }
  end

  # Is this {Actor} allowed to create a comment on activity?
  def can_comment?(activity)
    comment_relations(activity).any?
  end

  # Are there any relations that allow this actor to create a comment on activity?
  def comment_relations(activity)
    activity.relations.select{ |r| r.is_a?(Relation::Public) } |
      Relation.allow(self, 'create', 'activity', :in => activity.relations)
  end

  # Build a new {Contact} from each that has not inverse
  def pending_contacts
    received_contacts.pending.all.map do |c|
      c.inverse ||
        c.receiver.contact_to!(c.sender)
    end
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
    args = {}

    args[:type]  = type
    args[:owner] = self
    # Preserve this options
    [ :for, :object_type ].each do |opt|
      args[opt]   = options[opt]
    end

    if type == :home
      args[:followed] = Actor.followed_by(self).map(&:id)
    end

    # TODO: this is not scalling for sure. We must use a fact table in the future
    args[:relation_ids] =
      case type
      when :home
        # The relations from followings that can be read
        Relation.allow(self, 'read', 'activity').map(&:id)
      when :profile
        # FIXME: options[:relation]
        #
        # The relations that can be read by options[:for]
        options[:for].present? ?
          Relation.allow(options[:for], 'read', 'activity').map(&:id) :
          []
      else
        raise "Unknown type of wall: #{ type }"
      end

    Activity.wall args
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
    likes.joins(:contact).merge(Contact.sent_by(subject))
  end
  
  # Does subject like this {Actor}?
  def liked_by?(subject)
    liked_by(subject).present?
  end
  
  # Build a new activity where subject like this
  def new_like(subject)
    a = Activity.new :verb => "like",
                     :contact => subject.contact_to!(self)
    
    a.activity_objects << activity_object           
                    
    a             
  end
  
  #Returning whether an email should be sent for this object (Message or Notification).
  #Required by Mailboxer gem.
  def should_email?(object)
    return notify_by_email
  end

  # Use slug as parameter
  def to_param
    slug
  end
  
  private
  
  # After create callback
  def create_initial_relations
    Relation::Custom.defaults_for(self)
    Relation::Public.default_for(self)
  end

  # After create callback
  #
  # Save the profile if it is present. Otherwise create it
  def save_or_create_profile
    if profile.present?
      profile.actor_id = id
      profile.save!
    else
      create_profile
    end
  end
end
