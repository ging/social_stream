module FollowersHelper
  def follow_link_class(contact)
    "follow-link-#{ dom_id contact }"
  end
end
