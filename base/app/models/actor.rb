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
  
  validates_presence_of :name, :subject_type
  
  acts_as_messageable

  acts_as_url :name, :url_attribute => :slug
  
  has_one :profile, :dependent => :destroy

  has_many :avatars,
           :validate => true,
           :autosave => true
  has_one  :avatar,
           :conditions => { :active => true }
  		  
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

  has_many :relations,
           :dependent => :destroy

  scope :alphabetic, order('actors.name')

  scope :letter, lambda { |param|
    if param.present?
      where('actors.name LIKE ?', "#{ param }%")
    end
  }

  scope :name_search, lambda { |param|
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
  
  #Returning the email address of the model if an email should be sent for this object (Message or Notification).
  #If the actor is a Group and has no email address, an array with the email of the highest rank members will be
  #returned isntead.
  #
  #If no mail has to be sent, return nil.
  def mailboxer_email(object)
    #If actor has disabled the emails, return nil.
    return nil if !notify_by_email
    #If actor has enabled the emails and has email
    return "#{name} <#{email}>" if email.present?
    #If actor is a Group, has enabled emails but no mail we return the highest_rank ones.
    if (group = self.subject).is_a? Group
      relation = group.relation_customs.sort.first
      receivers = group.contact_actors(:direction => :sent, :relations => relation)
      emails = Array.new
      receivers.each do |receiver|
        receiver_emails = receiver.mailboxer_email(object)
        case receiver_emails
        when String
          emails << receiver_emails
        when Array
          receiver_emails.each do |receiver_email|
            emails << receiver_email
          end
        end
      end
    return emails
    end
  end
  
  # The subject instance for this actor
  def subject
    subtype_instance
  end

  # All the {Relation relations} defined by this {Actor}
  def relation_customs
    relations.where(:type => 'Relation::Custom')
  end

  # A given relation defined and managed by this actor
  def relation_custom(name)
    relation_customs.find_by_name(name)
  end

  # The {Relation::Public} for this {Actor} 
  def relation_public
    Relation::Public.of(self)
  end

  # The {Relation::Reject} for this {Actor} 
  def relation_reject
    Relation::Reject.of(self)
  end
 
  # All the {Actor actors} this one has relation with
  #
  # Options:
  # * type: Filter by the class of the contacts.
  # * direction: sent or received
  # * relations: Restrict the relations of considered ties. In the case of both directions,
  #   only relations belonging to {Actor} are valid. It defaults to relations of
  #   {Relation::Custom custom} and {Relation::Public public} types
  # * include_self: False by default, don't include this actor as subject even they have ties with themselves.
  # * load_subjects: True by default, make the queries for eager loading of contacts
  #
  def contact_actors(options = {})
    subject_types   = Array(options[:type] || self.class.subtypes)
    subject_classes = subject_types.map{ |s| s.to_s.classify }
    
    as = Actor.select("DISTINCT actors.*").
               where('actors.subject_type' => subject_classes)

    if options[:load_subjects].nil? || options[:load_subjects]
      as = as.includes(subject_types)
    end
    
    # Make another query for getting the actors in the other way
    if options[:direction].blank?
      rcv_opts = options.dup
      rcv_opts[:direction] = :received
      rcv_opts[:load_subjects] = false

      sender_ids = contact_actors(rcv_opts).map(&:id)

      as = as.where(:id => sender_ids)

      options[:direction] = :sent
    end
    
    case options[:direction]
    when :sent
      as = as.joins(:received_ties => :relation).merge(Contact.sent_by(self))
    when :received
      as = as.joins(:sent_ties => :relation).merge(Contact.received_by(self))
    else
      raise "How do you get here?!"
    end
    
    if options[:include_self].blank?
      as = as.where("actors.id != ?", self.id)
    end
    
    if options[:relations].present?
      as = as.merge(Tie.related_by(options[:relations]))
    else
      as = as.merge(Relation.where(:type => ['Relation::Custom', 'Relation::Public']))
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

  # Return a contact to subject.
  def contact_to(subject)
    sent_contacts.received_by(subject).first
  end

  # Return a contact to subject. Create it if it does not exist
  def contact_to!(subject)
    contact_to(subject) ||
      sent_contacts.create!(:receiver => Actor.normalize(subject))
  end

  # The {Contact} of this {Actor} to self (totally close!)
  def ego_contact
    contact_to!(self)
  end

  def sent_active_contact_ids
    @sent_active_contact_ids ||=
      load_sent_active_contact_ids
  end
  
  # By now, it returns a suggested {Contact} to another {Actor} without any current {Tie}
  #
  # @return [Contact]
  def suggestions(size = 1)
    candidates = Actor.where(Actor.arel_table[:id].not_in(sent_active_contact_ids + [id]))

    size.times.map {
      candidates.delete_at rand(candidates.size)
    }.compact.map { |a|
      contact_to! a
    }
  end
  
  # Set of ties sent by this actor received by subject
  def ties_to(subject)
    sent_ties.merge(Contact.received_by(subject))
  end

  # Is there any {Tie} sent by this actor and received by subject
  def ties_to?(subject)
    ties_to(subject).present?
  end

  # The {Tie ties} sent by this actor, plus the second grade ties
  def egocentric_ties
    @egocentric_ties ||=
      load_egocentric_ties
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

  # An {Activity} can be shared with multiple {audicences Audience}, which corresponds to a {Relation}.
  #
  # This method returns all the {relations Relation} that this actor can use to broadcast an Activity
  #
  #
  def activity_relations(subject, options = {})
    return relation_customs if Actor.normalize(subject) == self

    Array.new
  end

  # Are there any activity_relations present?
  def activity_relations?(*args)
    activity_relations(*args).any?
  end

  # Is this {Actor} allowed to create a comment on activity?
  #
  # We are allowing comments from everyone signed in by now
  def can_comment?(activity)
    return true

    comment_relations(activity).any?
  end

  # Are there any relations that allow this actor to create a comment on activity?
  def comment_relations(activity)
    activity.relations.select{ |r| r.is_a?(Relation::Public) } |
      Relation.allow(self, 'create', 'activity', :in => activity.relations)
  end

  def pending_contacts_count
    received_contacts.not_reflexive.pending.count
  end

  def pending_contacts?
    pending_contacts_count > 0
  end

  # Build a new {Contact} from each that has not inverse
  def pending_contacts
    received_contacts.pending.includes(:inverse).all.map do |c|
      c.inverse ||
        c.receiver.contact_to!(c.sender)
    end
  end

  # Count the contacts in common between this {Actor} and subject
  def common_contacts_count(subject)
    (sent_active_contact_ids & subject.sent_active_contact_ids).size
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
    avatar || avatars.build
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
                     :contact => subject.contact_to!(self),
                     :relation_ids => Array(subject.relation_public.id)
    
    a.activity_objects << activity_object           
                    
    a             
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
    Relation::Reject.default_for(self)
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

  # Calculate {#egocentric_ties}
  def load_egocentric_ties
    ties = sent_ties.includes(:contact).to_a

    contact_ids = ties.map{ |t| t.contact.receiver_id }

    second_grade_ties =
      contact_ids.
        map{ |i| Tie.sent_by(i) }.
        flatten

    ties + second_grade_ties
  end

  # Calculate {#sent_active_contact_ids}
  def load_sent_active_contact_ids
    sent_contacts.active.map(&:receiver_id)
  end
end
