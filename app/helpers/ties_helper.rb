module TiesHelper
  def suggestion_brief(subject)
    "18 contacts in common"
  end

  def suggestion_link(subject, relations)
    relation = relations[subject.class.to_s.underscore.to_sym] # relation = relations[:user]

    raise "Relation not provided for #{ subject.class.to_s.underscore }" if relation.blank?

    if relation=='follower'
        form_for Tie.new(:sender_id => current_user.actor.id,
                         :receiver_id => subject.actor.id,
                         :relation_name => relation ),
                      :remote => true do |f|
             f.hidden_field :receiver_id
             f.hidden_field :sender_id
             f.hidden_field :relation_name
             f.submit t('follow'), :class => "follow_btn"
        end




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
