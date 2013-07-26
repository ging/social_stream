module ContactsHelper
  def contact_count(actor)
    if user_signed_in?
      t 'contact.in_common', :count => current_subject.common_contacts_count(actor)
    else
      t 'contact.n', count: actor.sent_active_contact_count
    end
  end

  # Add contact button
  def contact_button(contact_or_actor)
    if user_signed_in?
      signed_in_contact_button contact_or_actor
    else
      anonymous_contact_button
    end
  end

  def signed_in_contact_button contact_or_actor
    c =
      if contact_or_actor.is_a?(Contact)
        contact_or_actor
      else
        current_actor.contact_to!(contact_or_actor)
      end

    if c.reflexive?
      t('subject.this_is_you')
    elsif can? :update, c
      render partial: "contacts/button",
             locals: { contact: c }
    else
      ""
    end
  end

  def anonymous_contact_button
    form_tag new_user_session_path do |f|
      submit_tag t('contact.new.button.zero')
    end
  end

  def current_contact_section? section
    params[:type] == section.to_s
  end

  def contact_select_options options
    if !options.empty? && options.first.respond_to?(:last) && Array === options.first.last
      grouped_options_for_select(options)
    else
      options_for_select(options)
    end
  end
end
