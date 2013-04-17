class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  PROVIDERS = Devise.omniauth_providers

  PROVIDERS.each do |provider|
    define_method(provider) do
      @user = User.find_or_create_for_oauth(env['omniauth.auth'], current_user)

      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication
      end
    end
  end
end
