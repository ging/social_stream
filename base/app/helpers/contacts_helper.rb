module ContactsHelper
  def contact_brief(subject)
    t 'contact.in_common', :count => current_subject.common_contacts_count(subject)
  end

  def contact_link(c)
    if c.reflexive?
      t('subject.this_is_you')
    else
      link_to(c.status,
              edit_contact_path(c),
              :title => t("contact.#{ c.action }.title", :name => c.receiver.name)) +
        "<br/>".html_safe +
        link_to(t('actor.delete'), contact_path(c), :action => :destroy, :confirm => t('actor.confirm_delete'), :remote => true)
    end

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
