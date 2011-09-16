class ProfilesController < InheritedResources::Base
  belongs_to_subjects(:singleton => true)

  load_and_authorize_resource :profile,
                              :through => SocialStream.subjects,
                              :singleton => true
  
  respond_to :html, :xml, :js
end
