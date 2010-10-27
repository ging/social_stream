module TiesHelper
  def tie_brief(tie)
    "18 contacts in common"
  end

  def tie_link(tie)
    # FIXME: tie name
    if tie.relation.granted
      # There is granted relation, so another user must confirmate it
      # We need to render ties#new with a message
      link_to t("#{ tie.relation.name }.new"),
              new_tie_path("tie[sender_id]" => tie.sender.id,
                           "tie[receiver_id]" => tie.receiver.id,
                           "tie[relation_name]" => tie.relation.name),
              :title => t("#{ tie.relation.name }.confirm_new",
                          :name => tie.receiver_subject.name),
              :remote => true

    else
      # Tie can be established at once.
      render :partial => 'ties/form',
                         :locals => { :tie => tie }
    end
  end

  def link_follow_state
      link_to("unfollow", home_path)
  end
end
