module ContactsHelper
  def contact_brief(contact)
    "N contacts in common"
  end

  # Show current ties from current user to actor, if they exist, or provide a link
  # to create new ties to actor
  def contact_to(a)
    if user_signed_in?
      if current_subject.ties_to?(a)
        current_subject.ties_to(a).map(&:relation_name).join(", ")
      else
        link_to t("contact.new.link"),
                edit_contact_path(current_subject.contact_to!(a)),
                                  :title => t("contact.new.title",
                                  :name => a.name)
      end
    else
      link_to t("contact.new.link"), new_user_session_path
    end
  end
end
