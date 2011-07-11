class ContactsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @contacts =
      current_subject.
        contact_subjects(:direction => :sent, :relations => params[:relation]){ |q|
          q.alphabetic.
            letter(params[:letter]).
            search(params[:search])
        }

    respond_to do |format|
      format.html { @contacts = Kaminari.paginate_array(@contacts).page(params[:page]).per(10) }
      format.js { @contacts = Kaminari.paginate_array(@contacts).page(params[:page]).per(10) }
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
