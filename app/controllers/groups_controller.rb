class GroupsController < InheritedResources::Base
  protected

  # Overwrite resource method to support permalink
  # See InheritedResources::BaseHelpers#resource
  def resource
    @group ||= end_of_association_chain.find_by_permalink!(params[:id])
  end
end
