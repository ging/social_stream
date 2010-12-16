module TiesHelper
  def tie_brief(tie)
    "N contacts in common"
  end

  def tie_link(tie)
    link_to t("contact.new"),
            new_tie_path("tie[sender_id]" => tie.sender.id,
                         "tie[receiver_id]" => tie.receiver.id),
            :title => t("contact.confirm_new",
                        :name => tie.receiver_subject.name),
            :remote => true
  end

  def link_follow_state
      link_to("Unfollow", home_path)
  end
end
