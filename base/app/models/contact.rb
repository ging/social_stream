# A {Contact} is an ordered pair of {Actor Actors},
# and therefore two {SocialStream::Models::Subject Subjects}.
#
# {Contact Contacts} are created at convenience (in the case of {Actor#suggestions suggestions},
# for instance), and they do not mean that there is a real link between those two
# {SocialStream::Models::Subject Subjects}. Link existance is stored as a {Tie}.
# When Alice adds Bob as contact, a new {Tie} is created with the {Contact} from Alice to
# Bob and the {Relation} that Alice chose.
#
# == Inverse Contacts
#
# Alice has a {Contact} to Bob. The inverse is the {Contact} from {Bob} to {Alice}.
# Inverse contacts are used to check if contacts are replied, for instance, if Bob added
# Alice as contact after she did so.
#
# Again, the Contact from Bob to Alice must have positive {Tie ties} to be active.
#
class Contact < ActiveRecord::Base
  # Send a message when this contact is created or updated
  attr_accessor :message

  belongs_to :inverse,
             :class_name => "Contact"

  belongs_to :sender,
             :class_name => "Actor"
  belongs_to :receiver,
             :class_name => "Actor"

  has_many :ties,
           :dependent  => :destroy,
           :before_add => :set_user_author

  has_many :relations,
           :through => :ties,
           :after_remove => :unset_follow_action

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

  scope :active, where(arel_table[:ties_count].gt(0))

  scope :positive, lambda {
    select("DISTINCT contacts.*").
      joins(:relations).
      merge(Relation.where(:type => Relation.positive_names))
  }

  scope :not_reflexive, where(arel_table[:sender_id].not_eq(arel_table[:receiver_id]))

  scope :pending, active.
                  positive.
                  not_reflexive.
                  joins("LEFT JOIN contacts AS inverse_contacts ON inverse_contacts.id = contacts.inverse_id").
                  where(arel_table[:inverse_id].eq(nil).or(arel_table.alias("inverse_contacts")[:ties_count].eq(0)))

  scope :related_by_param, lambda { |p|
    if p.present?
      joins(:ties).merge(Tie.where(:relation_id => p))
    end
  }

  validates_presence_of :sender_id, :receiver_id
  validates_presence_of :relation_ids, :on => :update
  validates_uniqueness_of :sender_id, :scope => :receiver_id
  validates_uniqueness_of :receiver_id, :scope => :sender_id

  after_create :set_inverse
  after_save :send_message

  def sender_subject
    sender.subject
  end

  def receiver_subject
    receiver.subject
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

  # Has this {Contact} any {Tie}?
  def established?
    ties_count > 0
  end

  # The {Contact} in the other way is established
  def replied?
    inverse_id.present? &&
      inverse.ties_count > 0
  end

  def positive_replied?
    inverse_id.present? &&
      self.class.positive.where(:id => inverse.id).any?
  end

  # The {ActivityVerb} corresponding to this {Contact}. If this contact is pending,
  # the other one was establised already, so this is going to "make-friend".
  # If it is not pending, the contact in the other way was not established, so this
  # is following
  def verb
    replied? ? "make-friend" : "follow"
  end

  # Record who creates ties in behalf of a group or organization
  #
  # Defaults to the sender actor, if it is a user
  def user_author
    @user_author ||
      build_user_author
  end

  # Set who creates ties in behalf of a group or organization
  def user_author= subject
    @user_author = (subject.nil? ? nil : Actor.normalize(subject))
  end

  # The sender of this {Contact} has establised positive sent to the receiver
  #
  # That means that there exists at least one {Tie} with a positive relation within them
  def sent?
    ties_count > 0 && relations.where(:type => Relation.positive_names).any?
  end

  # Is this {Contact} +new+ or +edit+ for {SocialStream::Models::Subject subject} ?
  #
  # action is +new+ when, despite of being created, it has not {Tie ties} or it has a {Tie} with a
  # {Relation::Reject reject relation}. 
  #
  # The contact's action is +edit+ when it has any {Tie} with a {Relation::Custom custom relation} or
  # a {Relation::Public public relation}
  #
  def action
    sent? ? 'edit' : ( replied? ? 'reply' : 'new' )
  end

  def status
    case action
    when 'edit'
      ties.includes(:relation).map(&:relation_name).join(", ")
    else
      I18n.t("contact.#{ action }.link")
    end
  end

  private

  def build_user_author
    return sender if sender.subject_type == "User"

    raise "Cannot determine user_author for #{ sender.inspect }"
  end

  # user_author is not preserved when the associated tie is build, in:
  #
  #   contact.ties.build
  #
  # so we need to preserve so the tie activity is recorded
  def set_user_author(tie)
    tie.contact.user_author = @user_author
  end

  # after_remove callback
  #
  # has_many collection=objects method does not trigger destroy callbacks,
  # so action#follow and follower_count will not be updated
  #
  # We need to update that status here
  #
  def unset_follow_action(relation)
    tie = Tie.new :contact => self,
                  :relation => relation

    tie.unset_follow_action
  end

  # Send a message to the contact receiver
  def send_message
    return if message.blank?

    sender.send_message(receiver, message, I18n.t("activity.verb.#{ verb }.#{ receiver.subject_type }.message", :name => sender.name))
  end

  def set_inverse
    
    inverse = self.class.sent_by(receiver_id).received_by(sender_id).first

    return if inverse.blank?

    update_attribute :inverse_id, inverse.id
    inverse.update_attribute :inverse_id, id
  end
end
