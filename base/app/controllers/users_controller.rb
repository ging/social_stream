class UsersController < InheritedResources::Base
  load_and_authorize_resource

  respond_to :html, :xml, :js
  
  def index
    @users = User.alphabetic.
                  letter(params[:letter]).
                  name_search(params[:search]).
                  tagged_with(params[:tag]).
                  page(params[:page]).per(10)


  end

  def show
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
