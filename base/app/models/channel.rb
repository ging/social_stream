# A {Channel} is the union of the three {Actors} that are involved in an {Activity}:
#
# * The author that creates a post, comment, etc. This can be a {User}, {Group}
#   or any kind of {SocialStream::Models::Subject subject}
# * The user_author representing the author. When users change session and
#   act in behalf of a {Group}, Social Stream still records which user is responsible
#   for an {Activity}
# * The owner in whose wall the Activity is performed.
#
class Channel < ActiveRecord::Base
  # Author can be any type of Actor: User, Group, etc.
  belongs_to :author,
             :class_name => "Actor"
  # Owner is the wall's subject this object is posted to
  belongs_to :owner,
             :class_name => "Actor"

  # UserAuthor is the real user behind the Author
  belongs_to :user_author,
             :class_name => "Actor"

  has_many :activity_objects

  validates_uniqueness_of :author_id,      :scope => [ :owner_id,  :user_author_id ]
  validates_uniqueness_of :owner_id,       :scope => [ :author_id, :user_author_id ]
  validates_uniqueness_of :user_author_id, :scope => [ :author_id, :owner_id ]

  scope :authored_by, lambda { |subject|
    id = Actor.normalize_id subject

    where(arel_table[:author_id].eq(id).or(arel_table[:user_author_id].eq(id)))
  }

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
end
