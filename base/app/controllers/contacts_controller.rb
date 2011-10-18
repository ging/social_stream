class ContactsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :exclude_reflexive, :except => [ :index, :pending ]

  def index
    @contacts =
      total_contacts.
              merge(Actor.letter(params[:letter])).
              merge(Actor.name_search(params[:search])).
              related_by_param(params[:relation])

    respond_to do |format|
      format.html { @contacts = @contacts.page(params[:page]).per(10) }
      format.js { @contacts = @contacts.page(params[:page]).per(10) }
      format.json { render :text => to_json(@contacts) }
    end
  end

  def edit
  end

  def update
    # FIXME: This should be in the model
    params[:contact][:relation_ids].present? &&
     params[:contact][:relation_ids].delete("0")

    if @contact.update_attributes(params[:contact])
      redirect_to @contact.receiver_subject
    else
      render :action => 'edit'
    end
  end

  def destroy
    @contact.relation_ids = [current_subject.relation_reject.id]

    respond_to do |format|
      format.js
    end
  end

  def pending
    total_contacts

    @contacts = current_subject.pending_contacts

    respond_to do |format|
      format.html {
        @contacts = Kaminari.paginate_array(@contacts).page(params[:page]).per(10)
        render :action => :index
      }
      format.js {
        @contacts = Kaminari.paginate_array(@contacts).page(params[:page]).per(10)
        render :action => :index
      }
    end
  end

  private

  def exclude_reflexive
    @contact = current_subject.sent_contacts.find params[:id]

    if @contact.reflexive?
      redirect_to home_path
    end
  end

  def to_json(contacts)
    contacts.map{ |c|
      if params[:form].present?
        {
          'key' => c.receiver_id.to_s,
          'value' => self.class.helpers.truncate_name(c.receiver.name)
        }
      else
        {
          'name'  => c.receiver.name,
          'url'   => polymorphic_url(c.receiver_subject),
          'image' => {
            'url' => root_url + c.receiver.logo.url
          }
        }
      end
    }.to_json
  end

  def total_contacts
    @total_contacts ||=
      Contact.sent_by(current_subject).
              joins(:receiver).merge(Actor.alphabetic).
              positive.
              select("actors.name")
  end
end
