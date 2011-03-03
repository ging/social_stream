class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_facebook_oauth(env['omniauth.auth'],current_user)
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
    else
      session['devise.facebook_data'] = env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end
end
