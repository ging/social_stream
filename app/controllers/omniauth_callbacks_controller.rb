class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    #print env['omniauth.auth']
    @user = User.find_or_create_for_facebook_oauth(env['omniauth.auth'],current_user)
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
    end
  end

  def linked_in
    #print env['omniauth.auth']
    @user = User.find_or_create_for_linkedin_oauth(env['omniauth.auth'],current_user)
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
    end
  end
end
