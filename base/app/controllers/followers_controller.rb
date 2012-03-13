class FollowersController < ApplicationController
  before_filter :authenticate_user!, :except => :index

  respond_to :html, :js

  def index
    @contacts =
      if params[:following]
        current_subject.sent_contacts
      else
        current_subject.received_contacts
      end

    respond_to do |format|
      format.html { @contacts = @contacts.page(params[:page]).per(20) }
      format.js { @contacts = @contacts.page(params[:page]).per(20) }
      format.json { render :text => to_json(@contacts) }
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
