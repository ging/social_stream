class ProfilesController < InheritedResources::Base
  belongs_to_subjects(:singleton => true)
end
