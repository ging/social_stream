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
      current_actor_contact_button contact_or_actor
    else
      anonymous_contact_button
    end
  end

  def current_actor_contact_button contact_or_actor
    c =
      if contact_or_actor.is_a?(Contact)
        if contact_or_actor.sender == current_actor
          contact_or_actor
        else
          current_actor.contact_to!(contact_or_actor.receiver)
        end
      else
        current_actor.contact_to!(contact_or_actor)
      end

    if c.reflexive?
      t('subject.this_is_you')
    else
      render :partial => "contacts/link_#{ SocialStream.relation_model }", :locals => { :contact => c }
    end
  end

  def anonymous_contact_button
    if SocialStream.relation_model == :follow
      form_tag new_user_session_path do |f|
        submit_tag t('contact.follow')
      end
    else
      link_to t("contact.new.link"), new_user_session_path
    end
  end

  def current_contact_section? section
    params[:type] == section.to_s
  end
end
