class ContactsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @contacts =
      current_subject.
        contacts(:direction => :sent){ |q|
          q.alphabetic.
            letter(params[:letter]).
            search(params[:search]).
            merge(Tie.related_by(current_subject.relation_customs.find_by_id(params[:relation])))
        }

    respond_to do |format|
      format.html { @contacts = Kaminari.paginate_array(@contacts).page(params[:page]).per(10) }
      format.js { @contacts = Kaminari.paginate_array(@contacts).page(params[:page]).per(10) }
      format.json { render :text => @contacts.map{ |c| { 'key' => c.name, 'value' => c.slug } }.to_json }
    end
  end

  def new
    @contact = Contact.new(current_actor, params[:id].to_i)
  end

  def edit
    @contact = Contact.new(current_actor, params[:id].to_i)
  end

  def update
    @contact = Contact.new(current_actor, params[:id].to_i)

    if @contact.update_attributes(params[:contact])
      redirect_to @contact.receiver_subject
    else
      render :action => 'edit'
    end
  end

  def suggestion
    @tie = current_subject.suggestion
    render :layout  => false
  end
end
