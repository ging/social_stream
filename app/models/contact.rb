# The link between two {Actor actors}
#
# Each {Contact} has many {Tie ties}, which determine the kind of the link through {Relation relations}
#
# = {Contact Contacts} and {Activity activities}
# Each {Activity} is attached to a {Contact}. When _Alice_ post in _Bob_'s wall,
# the {Activity} is attached to the {Contact} from _Alice_ to _Bob_
#
# * The sender of the {Contact} is the author of the {Activity}.
#   It is the user that uploads a resource to the website or the social entity that
#   originates the {Activity} (for example: add as contact).
#
# * The receiver {Actor} of the {Contact} is the receiver of the {Activity}.
#   The {Activity} will appear in the wall of the receiver, depending on the permissions
#
class Contact < ActiveRecord::Base
  # Send a message when this contact is created or updated
  attr_accessor :message

  belongs_to :inverse,
             :class_name => "Contact"

  belongs_to :sender,
             :class_name => "Actor",
             :include => SocialStream.subjects
  belongs_to :receiver,
             :class_name => "Actor",
             :include => SocialStream.subjects

  has_many :ties
  has_many :relations, :through => :ties

  scope :sent_by, lambda { |a|
    where(:sender_id => Actor.normalize_id(a))
  }

  scope :received_by, lambda { |a|
    where(:receiver_id => Actor.normalize_id(a))
  }

  scope :sent_or_received_by, lambda { |a|
    where(arel_table[:sender_id].eq(Actor.normalize_id(a)).
          or(arel_table[:receiver_id].eq(Actor.normalize_id(a))))
  }

  scope :recent, order("contacts.created_at DESC")

  scope :pending, joins("LEFT JOIN contacts AS inverse_contacts ON inverse_contacts.id = contacts.inverse_id").
                  where(arel_table[:inverse_id].eq(nil).or(arel_table.alias("inverse_contacts")[:ties_count].eq(0)))

  scope :active, where(arel_table[:ties_count].gt(0))

  validates_presence_of :sender_id, :receiver_id

  after_create :set_inverse
  after_create :create_activity
  after_create :send_message

  def sender_subject
    sender.try(:subject)
  end

  def receiver_subject
    receiver.try(:subject)
  end

  # Does this {Contact} have the same sender and receiver?
  def reflexive?
    sender_id == receiver_id
  end

  # Find or create the inverse {Contact}
  def inverse!
    inverse ||
      receiver.contact_to!(sender)
  end

  # Is not the inverse of this {Contact}
  def pending?
    inverse &&
      inverse.ties_count > 0
  end

  private

  # Create the related {Activity}
  def create_activity
    return if relations.blank?

    Activity.create! :contact => self,
                     :relation_ids => relation_ids,
                     :activity_verb => ActivityVerb[verb]
  end

  def verb
    pending? ? "follow" : "make-friend"
  end

  # Send a message to the contact receiver
  def send_message
    if message.present?
      sender.send_message(receiver, message, I18n.t("activity.verb.#{ contact_verb }.#{ receiver.subject_type }.message", :name => sender.name))
    end
  end

  def set_inverse
    inverse = Contact.sent_by(receiver_id).received_by(sender_id).first

    return if inverse.blank?

    update_attribute :inverse_id, inverse.id
    inverse.update_attribute :inverse_id, id
  end
end
