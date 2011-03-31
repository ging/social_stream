class ProfilesController < InheritedResources::Base
  belongs_to_subjects(:singleton => true)
  
  respond_to :html, :xml, :js
end
