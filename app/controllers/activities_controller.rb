class ActivitiesController < InheritedResources::Base
  belongs_to_subjects

  def index
    index! do
      format.html { render(:partial => 'wall') if params[:wall].present? }
    end
  end
end
