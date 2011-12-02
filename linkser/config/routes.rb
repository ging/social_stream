Rails.application.routes.draw do  
  match 'linkser_parse' => 'linkser#index', :as => :linkser_parse  
end
