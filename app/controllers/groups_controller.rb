class GroupsController < InheritedResources::Base
  
  respond_to :html, :xml, :js
  
  def index
    if params[:search]
      @groups = Group.search("%"+params[:search]+"%").paginate(:per_page => 10, :page => params[:page])
    else
      if params[:letter] && params[:letter]!="undefined"
        @groups = Group.search(params[:letter]+"%").paginate(:per_page => 10, :page => params[:page])
      else
        @groups = Group.alphabetic.paginate(:per_page => 10, :page => params[:page])
      end
    end
  end


  
  protected

  # Overwrite resource method to support slug
  # See InheritedResources::BaseHelpers#resource
  def resource
    @group ||= end_of_association_chain.find_by_slug!(params[:id])
  end
end
