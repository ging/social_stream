class ContactsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @contacts =
      Contact.sent_by(current_subject).
              joins(:receiver).merge(Actor.alphabetic).
              merge(Actor.letter(params[:letter])).
              merge(Actor.search(params[:search]))
    
    if params[:pending].present?
      @contacts = 
        Contact.received_by(current_subject).
              joins(:sender).merge(Actor.alphabetic).
              merge(Actor.letter(params[:letter])).
              merge(Actor.search(params[:search])).
              pending.
              not_reflexive
    end

    respond_to do |format|
      format.html { @contacts = @contacts.page(params[:page]).per(10) }
      format.js { @contacts = @contacts.page(params[:page]).per(10) }
      format.json { render :text => @contacts.map{ |c| { 'key' => c.actor_id.to_s, 'value' => self.class.helpers.truncate_name(c.name) } }.to_json }
    end
  end

  def edit
    @contact = current_subject.sent_contacts.find params[:id]
  end

  def update
    @contact = current_subject.sent_contacts.find params[:id]

    # This should be in the model
    if params[:contact][:relation_ids].present?
      params[:contact][:relation_ids].delete("gotcha")
    end

    if @contact.update_attributes(params[:contact])
      redirect_to @contact.receiver_subject
    else
      render :action => 'edit'
    end
  end

  def destroy
    @contact = current_subject.sent_contacts.find params[:id]
    
    @contact.relation_ids = [current_subject.relation_public.id]

    respond_to do |format|
      format.js
    end
  end
end
