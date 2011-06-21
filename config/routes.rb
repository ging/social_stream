Rails.application.routes.draw do
  resources :documents
  match 'documents/:id/download' => 'documents#download'
end