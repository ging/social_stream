class GroupsController < InheritedResources::Base
  before_filter :authenticate_user!, :except => [ :index, :show ]

  # Set group founder to current_subject
  # Must do before authorization
  before_filter :set_founder, :only => :new

  load_and_authorize_resource

  respond_to :html, :js

  def index
    @groups = Group.most(params[:most]).
                    alphabetic.
                    letter(params[:letter]).
                    name_search(params[:search]).
                    tagged_with(params[:tag]).
                    page(params[:page]).per(10)

  end

  def show
  end

  def create
    create! do |success, failure|
      success.html {
        self.current_subject = @group
        redirect_to :home
      }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html {
        self.current_subject = current_user
        redirect_to :home
      }
    end
  end

  protected

  # Overwrite resource method to support slug
  # See InheritedResources::BaseHelpers#resource
  def resource
    @group ||= end_of_association_chain.find_by_slug!(params[:id])
  end

  private

  def set_founder
    params[:group]               ||= {}
    params[:group][:_contact_id] ||= current_subject.ego_contact.id
  end
end
