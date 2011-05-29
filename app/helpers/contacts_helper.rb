module ContactsHelper
  def contact_brief(contact)
    "N contacts in common"
  end

  # Show current ties from current user to actor, if they exist, or provide a link
  # to create new ties to actor
  def contact_to(a)
    if user_signed_in?
      if current_subject.ties_to(a).present?
        current_subject.ties_to(a).map(&:relation_name).join(", ")
      else
        new_contact_link(Contact.new(current_subject, a))
      end
    else
      link_to t("contact.new.link"), new_user_session_path
    end
  end

  def new_contact_link(contact)
    link_to t("contact.new.link"),
            new_contact_path(:id => contact.to_param),
            :title => t("contact.new.title",
                        :name => contact.receiver.name)
  end
end
