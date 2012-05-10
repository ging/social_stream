# The {ActivityObject} is any object that receives actions. Examples are
# creating post, liking a comment, contacting a user. 
#
# = ActivityObject subtypes
# All post, comment and user are {SocialStream::Models::Object objects}.
# Social Stream privides 3 {ActivityObject} subtypes, {Post}, {Comment} and
# {Actor}. The application developer can define as many {ActivityObject} subtypes
# as required.
# Objects are added to +config/initializers/social_stream.rb+
#
class ActivityObject < ActiveRecord::Base
  attr_reader :_activity_parent_id

  # ActivityObject is a supertype of SocialStream.objects
  supertype_of :object

  acts_as_taggable

  has_many :activity_object_audiences, :dependent => :destroy
  has_many :relations, :through => :activity_object_audiences

  has_many :activity_object_activities, :dependent => :destroy
  has_many :activities, :through => :activity_object_activities

  has_many :received_actions,
           :class_name => "ActivityAction",
           :dependent  => :destroy,
           :autosave   => true
  has_many :followers,
           :through => :received_actions,
           :source  => :actor,
           :conditions => { 'activity_actions.follow' => true }

  # Associations for indexing
  has_many :author_actions,
           :class_name => "ActivityAction",
           :conditions => { :author => true }
  has_many :owner_actions,
           :class_name => "ActivityAction",
           :conditions => { :owner => true }

  has_many :activity_object_properties,
           :dependent => :destroy
  has_many :object_properties,
           :through => :activity_object_properties,
           :source => :property
  has_many :activity_object_holders,
           :class_name  => "ActivityObjectProperty",
           :foreign_key => :property_id,
           :dependent   => :destroy
  has_many :object_holders,
           :through => :activity_object_holders,
           :source  => :activity_object

  before_validation :fill_relation_ids, :if => lambda { |obj| obj.object_type != "Actor" }

  validates_presence_of :object_type
  validate :allowed_relations, :if => lambda { |obj| obj.object_type != "Actor" }

  # TODO: This is currently defined in lib/social_stream/models/object.rb
  #
  # Need to fix activity_object_spec_helper before activating it
  #
  # validates_presence_of :author_id, :owner_id, :user_author_id, :unless => :acts_as_actor?
  # after_create :create_post_activity, :unless => :acts_as_actor?

  scope :authored_by, lambda { |subject|
    joins(:received_actions).
      merge(ActivityAction.sent_by(subject).where(:author => true))
  }

  scope :not_authored_by, lambda { |subject|
    joins(:received_actions).
      merge(ActivityAction.not_sent_by(subject).where(:author => true))
  }

  scope :owned_by, lambda { |subject|
    joins(:received_actions).
      merge(ActivityAction.sent_by(subject).where(:owner => true))
  }

  scope :followed, order("activity_objects.follower_count DESC")

  scope :followed_by, lambda { |subject|
    joins(:received_actions).
      merge(ActivityAction.sent_by(subject).where(:follow => true))
  }

  scope :shared_with, lambda { |subject|
    joins(:activity_object_audiences).
      merge(ActivityObjectAudience.where(:relation_id => Relation.ids_shared_with(subject)))
  }

  def received_role_action(role)
    received_actions.
      find{ |a| a.__send__ "#{ role }?" }
  end

  %w{ author user_author owner }.each do |role|
    code = <<-EOC
      def #{ role }_id                     # def author_id
        received_role_action(:#{ role }).  #   received_role_action(:author).
          try(:actor_id)                   #     try(:actor_id)
      end                                  # end

      def #{ role }_id=(actor_id)                    # def author_id=(actor_id)
        action =                                     #   action =
          received_actions.                          #     received_actions.
            find{ |a| a.actor_id == actor_id }       #       select{ |a| a.actor_id == actor_id }
                                                     #
        if action                                    #   if action 
          action.#{ role } = true                    #     action.author = true
        else                                         #   else
          received_actions.                          #     received_actions.
            build :actor_id  => actor_id,            #       build :actor_id => actor_id,
                  :#{ role } => true                 #             :author   => true
        end                                          #   end
                                                     #
        actor_id                                     #  actor_id
      end                                            # end

      def #{ role }                        # def author
        received_role_action(:#{ role }).  #   received_role_action(:author).
          try(:actor)                      #     try(:actor)
      end                                  # end

      def #{ role }=(actor)           # def author=(actor)
        self.#{ role }_id =           #   self.author_id =
          Actor.normalize_id(actor)   #     Actor.normalize_id(actor)
      end                             # end

      def #{ role }_subject # def author_subject
        #{ role }.subject   #   author.subject
      end                   # end

    EOC

    class_eval code, __FILE__, __LINE__ - code.lines.count - 2
  end

  # subject was the author, user author or owner of this {ActivityObject}?
  def authored_or_owned_by?(subject)
    return false if subject.blank?

    received_actions.
      merge(ActivityAction.authored_or_owned_by(subject)).
      any?
  end

  # Was the author represented when this {ActivityObject} was created?
  def represented_author?
    author_id != user_author_id
  end

  # The object of this activity object
  def object
    subtype_instance.is_a?(Actor) ?
      subtype_instance.subject :
      subtype_instance
  end

  # Does this {ActivityObject} has {Actor}?
  def acts_as_actor?
    object_type == "Actor"
  end

  def actor!
    actor || raise("Unknown Actor for ActivityObject: #{ inspect }")
  end

  # Return the {Action} model to an {Actor}
  def action_from(actor)
    received_actions.sent_by(actor).first
  end

  # The activity in which this activity_object was created
  def post_activity
    activities.includes(:activity_verb).where('activity_verbs.name' => 'post').first
  end

  # Build the post activity when this object is not saved
  def build_post_activity
    Activity.new :author       => author,
                 :user_author  => user_author,
                 :owner        => owner,
                 :relation_ids => relation_ids
  end

  def _activity_parent
    @_activity_parent ||= Activity.find(_activity_parent_id)
  end

  def _activity_parent_id=(id)
    self.relation_ids = Activity.find(id).relation_ids
    @_activity_parent_id = id
  end

  private

  def fill_relation_ids
    return if relation_ids.present? || author.blank? || owner.blank?

    @valid_relations = true

    self.relation_ids =
      if SocialStream.relation_model == :custom
        owner.
          relations.
          allowing('read', 'activity').
          map(&:id)
      else
        Array.wrap Relation::Public.instance.id
      end
  end

  # validate method
  #
  # check relations are included in 
  def allowed_relations
    return if @valid_relations

    allowed_rels =
      owner.relations.allowing('read', 'activity') + 
      Relation::Single.allowing('read', 'activity')

    if (relation_ids - allowed_rels.map(&:id)).any?
      errors.add(:relation_ids, "not allowed: #{ relation_ids }, author_id: #{ author_id }, owner_id: #{ owner_id }")
    end
  end


  def create_post_activity
    create_activity "post"
  end

  def create_update_activity
    create_activity "update"
  end

  def create_activity(verb)
    a = Activity.new :verb         => verb,
                     :author_id    => author_id,
                     :user_author  => user_author,
                     :owner        => owner,
                     :relation_ids => relation_ids,
                     :parent_id    => _activity_parent_id

    a.activity_objects << self

    a.save!
  end
end
