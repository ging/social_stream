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
  @subtypes_name = :object
  include SocialStream::Models::Supertype

  acts_as_taggable
  
  # Author can be any type of Actor: User, Group, etc.
  belongs_to :author,
             :class_name => "Actor"
  # Owner is the wall's subject this object is posted to
  belongs_to :owner,
             :class_name => "Actor"

  # UserAuthor is the real user behind the Author
  belongs_to :user_author,
             :class_name => "Actor"

  has_many :activity_object_activities, :dependent => :destroy
  has_many :activities, :through => :activity_object_activities

  validates_presence_of :object_type

  # The object of this activity object
  def object
    subtype_instance.is_a?(Actor) ?
      subtype_instance.subject :
      subtype_instance
  end

  # The {SocialStream::Models::Subject subject} author
  def author_subject
    author.subject
  end

  # The {SocialStream::Models::Subject subject} owner
  def owner_subject
    owner.subject
  end

  # The {SocialStream::Models::Subject subject} user actor
  def user_author_subject
    user_author.subject
  end

  # The activity in which this activity_object was created
  def post_activity
    activities.includes(:activity_verb).where('activity_verbs.name' => 'post').first
  end

  # Does this {ActivityObject} has {Actor}?
  def acts_as_actor?
    object_type == "Actor"
  end
end
