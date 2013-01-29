Rails.application.routes.draw do
  match 'oauth2/authorize', to: 'authorizations#new'
  post  'oauth2/token', to: proc { |env| SocialStream::Oauth2Server::TokenEndpoint.new.call(env) }

  resources :authorizations, only: :create

  namespace "site" do
    resources :clients
  end
end
