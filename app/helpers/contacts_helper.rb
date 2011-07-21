module ContactsHelper
  def contact_brief(contact)
    "N contacts in common"
  end

  def contact_status(c)
    c.established? ?
      c.ties.map(&:relation_name).join(", ") :
      t("contact.new.link")
  end

  def contact_link(c)
    link_to contact_status(c),
            edit_contact_path(c),
            :title => t("contact.#{ c.action }.title", :name => c.receiver.name)

  end

  # Show current ties from current user to actor, if they exist, or provide a link
  # to create new ties to actor
  def contact_to(a)
    if user_signed_in?
      contact_link current_subject.contact_to!(a)
    else
      link_to t("contact.new.link"), new_user_session_path
    end
  end
end
