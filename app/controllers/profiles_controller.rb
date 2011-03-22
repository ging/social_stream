class ProfilesController < InheritedResources::Base
  belongs_to *(SocialStream.subjects + [{ :polymorphic => true, :finder => :find_by_slug!, :singleton => true }])
end
