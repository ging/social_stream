class UsersController < InheritedResources::Base
  load_and_authorize_resource

  respond_to :html, :xml, :js
  
  def index
    @users = User.alphabetic.
                  letter(params[:letter]).
                  search(params[:search]).
                  tagged_with(params[:tag]).
                  paginate(:per_page => 10, :page => params[:page])

    index! do |format|
      format.html { render :layout => (user_signed_in? ? 'application' : 'frontpage') }
    end
  end

  # Supported through devise
  def new; end; def create; end
  # Not supported yet
  def destroy; end

  protected

  # Overwrite resource method to support slug
  # See InheritedResources::BaseHelpers#resource
  def resource
    @user ||= end_of_association_chain.find_by_slug!(params[:id])
  end
end
