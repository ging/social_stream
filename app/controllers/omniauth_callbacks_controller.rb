class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    #print env['omniauth.auth']
    @user = User.find_or_create_for_facebook_oauth(env['omniauth.auth'],current_user)
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
    else
      session['devise.facebook_data'] = env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end

  def linked_in
    print "LINKEDIN DATA:"
    print env['omniauth.auth']
    print "LINKEDIN EXTRAS:"
    print env['omniauth.auth']['extras']['user_hash']
  end
end
