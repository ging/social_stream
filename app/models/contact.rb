# Convenience class for managing all the ties between two
# actors at once
class Contact
  extend ActiveModel::Naming

  ATTRS = [ :message, :relation_ids ]

  attr_accessor :sender, :receiver, :message

  def initialize(sender, receiver)
    @sender = Actor.normalize(sender)
    @receiver = Actor.normalize(receiver)
  end

  def sender_subject
    sender.subject
  end

  def receiver_subject
    receiver.subject
  end

  def relation_ids
    @relation_ids ||=
      sender.ties_to(receiver).map(&:relation_id)
  end

  def relation_ids=(ids)
    # Gotcha related with empty arrays in forms:
    #
    # http://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-check_box
    ids.delete("gotcha")

    @relation_ids =
      ids.map{ |i|
        # We must check that sender has those relation
        sender.relations.find(i).id
      }
  end

  def id
    receiver.id
  end

  def to_param
    id
  end

  def to_key
    [id]
  end

  def update_attributes(attrs)
    ATTRS.each do |attr|
      if attrs.key?(attr.to_s)                  # if attrs.key?("message")
        __send__ "#{ attr }=", attrs[attr.to_s] #   self.message = attrs["message"]
      end                                       # end
    end

    save

    # TODO: errors
    true
  end

  def save
    @previous = sender.ties_to(receiver).all

    @continued = @previous.select{ |t| relation_ids.include?(t.relation_id) }

    Tie.transaction do
      # Change previous ties to not intended
      # Do not destroy them, because there can be activities attached to them
      (@previous - @continued).each do |t|
        t.update_attribute :intended, false
      end

      # Activate tie or create it
      new_relation_ids = relation_ids - @continued.map(&:relation_id)

      # There can be old ties that where marked as intented but
      # now they are activated again
      @reactivated = sender.
                     ties_to(receiver).
                     related_by(new_relation_ids)

      @reactivated.each{ |t| t.update_attribute :intended, true }
       
      @new = (new_relation_ids - @reactivated.map(&:relation_id)).map do |i|
        sender.sent_ties.create! :receiver_id => receiver.id,
                                 :relation_id => i
      end

      create_activity
      send_message
    end
  end

  private

  # Create the related {Activity}
  def create_activity
    return if @previous.present?

    @new.each do |t|
      Activity.create! :_tie => t,
                       :activity_verb => ActivityVerb[verb]
    end
  end

  def verb
    @new.first.replied? ? "make-friend" : "follow"
  end

  # Send a message to the contact receiver
  def send_message
    if message.present?
      sender.send_message(receiver, message, I18n.t("activity.verb.#{ contact_verb }.#{ receiver.subject_type }.message", :name => sender.name))
    end
  end
end
