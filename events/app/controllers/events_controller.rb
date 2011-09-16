class EventsController < InheritedResources::Base
  # Set group founder to current_subject
  # Must do before authorization
  #before_filter :authenticate_user!

  before_filter :set_founder, :only => :create

  #load_and_authorize_resource

  respond_to :html, :js

  def create
    create! do |success, failure|
      success.html {
        self.current_subject = @event
        redirect_to [current_subject, :profile]
      }

    end

  end

  def edit
    @event = Event.find(params[:id])

  end

  def index
    @events = Event.most(params[:most]).
                    alphabetic.
                    letter(params[:letter]).
                    search(params[:search]).
                    tagged_with(params[:tag]).
                    page(params[:page]).per(10)
  end

  def manage
    if params[:live].nil?
            @events = Event.
                    most(params[:most]).
                    alphabetic.letter(params[:letter]).
                    search(params[:search]).
                    tagged_with(params[:tag]).                    
                    page(params[:page]).per(10)
    else
      @events = Event.
                    live_events().
                    alphabetic.letter(params[:letter]).
                    search(params[:search]).
                    tagged_with(params[:tag]).                    
                    page(params[:page]).per(10)
#@groups = Group.most(params[:most]).
#                    alphabetic.
#                    letter(params[:letter]).
#                    search(params[:search]).
#                    tagged_with(params[:tag]).
#                    page(params[:page]).per(10)
    end
    index! do |format|
      format.html { render :layout => (user_signed_in? ? 'application' : 'frontpage') }
    end
  end

  def outline

  end

  protected

  # Overwrite resource method to support slug
  # See InheritedResources::BaseHelpers#resource
  def resource
    @event ||= end_of_association_chain.find_by_slug!(params[:id])
  end

  private

  def set_founder
    return unless user_signed_in?

    params[:event]            ||= {}
    params[:event][:_founder] ||= current_subject.slug
  end

end
