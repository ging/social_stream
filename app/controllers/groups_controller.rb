class GroupsController < InheritedResources::Base
  def index
    if params[:search]
      @groups = Group.find_by_sql("SELECT * FROM groups,actors WHERE groups.actor_id=actors.id AND actors.name LIKE '%"+params[:search]+"%'").paginate(:per_page => 10, :page => params[:page])
    else
      if params[:letter] && params[:letter]!="undefined"
        @groups = Group.find_by_sql("SELECT * FROM groups,actors WHERE groups.actor_id=actors.id AND actors.name LIKE '"+params[:letter]+"%'").paginate(:per_page => 10, :page => params[:page])
      else
        @groups = Group.alphabetic.paginate(:per_page => 10, :page => params[:page])
      end
    end
  end
  protected

  # Overwrite resource method to support permalink
  # See InheritedResources::BaseHelpers#resource
  def resource
    @group ||= end_of_association_chain.find_by_permalink!(params[:id])
  end
end
