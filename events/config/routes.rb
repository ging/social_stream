Rails.application.routes.draw do

  match "/events/manage" => "events#manage"
  match "/sessions/delete/:id" => "sessions#delete"
  # Social Stream subjects configured in config/initializers/social_stream.rb

  SocialStream.subjects.each do |actor|
    resources actor.to_s.pluralize do
      resources :events do
        resource :agendas do
          resources :sessions
        end
      end
    end
  end

  match "events/:id/agenda" => "agendas#show"
  match "events/:id/sessions" => "sessions#show"
  match "events/:id/sessions/create" => "sessions#create"


  match "events/:id/agenda/get_sessions" => "agendas#get_sessions"

  match "sessions/:id/move" => "sessions#move"
  match "sessions/:id/resize" => "sessions#resize"
  match "sessions/:id/destroy" => "sessions#destroy"
  match "sessions/:id/new" => "sessions#new"
  match "sessions/:id/create" => "sessions#create"
  match "sessions/:id/update" => "sessions#update"
end
