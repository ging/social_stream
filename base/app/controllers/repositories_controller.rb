class RepositoriesController < ApplicationController
  before_filter :profile_or_current_subject!

  def show
    respond_to do |format|
      format.html {
        collection

        render collection if request.xhr?
      }

      format.json { render :json => collection }
    end
  end

  def search
    render SocialStream::Search.search(params[:q], current_subject, mode: :repository, owner: profile_subject!)
  end

  private

  def collection
    @collection ||=
      ActivityObject.
        select("DISTINCT activity_objects.*").
        where(object_type: SocialStream.repository_models.map(&:to_s).map(&:classify)).
        includes(SocialStream.repository_models).
        collection(profile_or_current_subject, current_subject).
        page(params[:page])
  end
end
 
