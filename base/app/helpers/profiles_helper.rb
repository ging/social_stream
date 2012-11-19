module ProfilesHelper
  #Returns the value if user is signed in or a link to sign in view
  def show_if_signed_in(info)
    return info if user_signed_in?
    return link_to t('profile.must_be_signed_id'), new_user_session_path
  end
  
end
