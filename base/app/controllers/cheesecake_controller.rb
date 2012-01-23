class CheesecakeController < ApplicationController

  before_filter :authenticate_user!
  def index
    @actors = current_subject.contact_actors(:direction => :sent)
  end

  def update
    changes = JSON.parse params[:contacts_save_changes] if params[:contacts_save_changes].is_a? String

    if (actors = changes["actors"]).present? and actors.is_a? Array
      actors.each do |actor|
        next if (contact = Contact.find_by_id(actor["extraInfo"].to_i)).nil?
        contact.relation_ids = actor["subsectors"]
      end
    end

    @actors = current_subject.contact_actors(:direction => :sent)
  end

end
