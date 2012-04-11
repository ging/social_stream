class FollowersController < ApplicationController
  before_filter :authenticate_user!, :except => :index

  respond_to :html, :js

  def index
    @followings = current_subject.following_actor_objects.includes(:actor)
    @followers = current_subject.followers

    respond_to do |format|
      format.html
      format.json { render :text => to_json(@followers) }
    end
  end

  def update
    current_contact.relation_ids = Array.wrap(Relation::Follow.instance.id)

    respond_to :js
  end

  def destroy
    current_contact.relation_ids = Array.new

    respond_to :js
  end

  private

  def current_contact
    @contact ||=
      current_subject.sent_contacts.find params[:id]
  end
end
