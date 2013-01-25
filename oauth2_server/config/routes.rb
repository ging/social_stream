Rails.application.routes.draw do
  match 'oauth2/authorize', to: 'authorizations#new'
#  post  'oauth2/token', to: proc { |env| TokenEndpoint.new.call(env) }

  namespace "site" do
    resources :clients
  end
end
