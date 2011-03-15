class GroupsController < InheritedResources::Base
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
  
  def edit
    @group = Group.find_by_permalink!(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @group }
    end
  end

  
  protected

  # Overwrite resource method to support permalink
  # See InheritedResources::BaseHelpers#resource
  def resource
    @group ||= end_of_association_chain.find_by_permalink!(params[:id])
  end
end
