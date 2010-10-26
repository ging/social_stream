module TiesHelper
  def suggestion_brief(subject)
    "18 contacts in common"
  end

  def suggestion_link(subject, relations)
    relation = relations[subject.class.to_s.underscore.to_sym] # relation = relations[:user]

    raise "Relation not provided for #{ subject.class.to_s.underscore }" if relation.blank?

    if relation=='follower'
      render :partial => 'ties/form_follower',
                         :locals => { :subject => subject, :relation => relation }

    else
      link_to t("tie.suggestion.#{ relation }.new"),
              new_tie_path("tie[sender_id]" => current_user.actor.id,
                           "tie[receiver_id]" => subject.actor.id,
                           "tie[relation_name]" => relation),
              :class => 'boxy',
              :title => t("tie.suggestion.#{ relation }.confirm_new", :name => subject.name)


    end

  end
end
