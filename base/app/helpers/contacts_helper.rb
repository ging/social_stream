module ContactsHelper
  def contact_brief(subject)
    t 'contact.in_common', :count => current_subject.common_contacts_count(subject)
  end

  def contact_link(c)
    if c.reflexive?
      t('subject.this_is_you')
    else
      render :partial => "contacts/link_#{ SocialStream.relation_model }", :locals => { :contact => c }
    end

  end

  # Show current ties from current user to actor, if they exist, or provide a link
  # to create new ties to actor
  def contact_to(a)
    if user_signed_in?
      contact_link current_subject.contact_to!(a)
    else
      if SocialStream.relation_model == :follow
        form_tag new_user_session_path do |f|
          submit_tag t('contact.follow')
        end
      else
        link_to t("contact.new.link"), new_user_session_path
      end
    end
  end
end
