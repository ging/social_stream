class ContactsController < ApplicationController
  before_filter :authenticate_user!
  def index
    if params[:pending].present?
      pending
    return
    end
    @contacts =
    Contact.sent_by(current_subject).
            joins(:receiver).merge(Actor.alphabetic).
            merge(Actor.letter(params[:letter])).
            merge(Actor.name_search(params[:search])).
            active

    respond_to do |format|
      format.html { @contacts = @contacts.page(params[:page]).per(10) }
      format.js { @contacts = @contacts.page(params[:page]).per(10) }
      format.json { render :text => @contacts.map{ |c| { 'key' => c.receiver_id.to_s, 'value' => self.class.helpers.truncate_name(c.receiver.name) } }.to_json }
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

    @contact.relation_ids = [current_subject.relation_reject.id]

    respond_to do |format|
      format.js
    end
  end

  def pending

    @contacts = current_subject.pending_contacts

    respond_to do |format|
      format.html { @contacts = Kaminari.paginate_array(@contacts).page(params[:page]).per(10) }
      format.js { @contacts = Kaminari.paginate_array(@contacts).page(params[:page]).per(10) }
      format.json { render :text => @contacts.map{ |c| { 'key' => c.receiver_id.to_s, 'value' => self.class.helpers.truncate_name(c.receiver.name) } }.to_json }
    end
  end
end
