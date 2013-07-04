class ContactsController < ApplicationController
  before_filter :authenticate_user!, except: [ :index ]
  load_and_authorize_resource except: [ :index, :suggestion, :pending ]
  before_filter :exclude_reflexive,  except: [ :index, :suggestion, :pending ]

  helper_method :current_subject_contacts_to

  def index
    params[:subject] = subject = profile_or_current_subject!
    params[:d]    ||= 'sent'
    params[:type] ||= subject.class.contact_index_models.first.to_s

    @contacts = Contact.index(params)

    respond_to do |format|
      format.html { render current_subject_contacts_to(@contacts) if request.xhr? }
      format.json { render json: @contacts.map(&:receiver), helper: self }
    end
  end

  def update
    # Record who is manipulating the contact, mainly in groups
    @contact.user_author = current_user

    # FIXME: This should be in the model
    params[:contact][:relation_ids].present? &&
      params[:contact][:relation_ids].delete("0")

    @contact.update_attributes(params[:contact])

    respond_to do |format|
      format.html {
        if @contact.errors.blank?
          redirect_to @contact.receiver_subject
        else
          render :action => 'edit'
        end
      }

      format.js
    end
  end

  def destroy
    relation_ids = []

    if params[:reject].present?
      relation_ids << Relation::Reject.instance.id
    end

    @contact.relation_ids = []

    respond_to do |format|
      format.js
    end
  end

  # Return a suggestion for this contact
  def suggestion
    @contact = current_subject.suggestions.first

    respond_to do |format|
      format.html { @contact.present? ? render(partial: @contact) : render(text: "") }
      format.json { render json: @contact }
    end
  end

  def pending
    @contact = current_subject.pending_contacts.last

    respond_to do |format|
      format.html { @contact.present? ? render(partial: @contact) : render(text: "") }
      format.json { render json: @contact }
    end
  end

  protected

  def current_subject_contacts_to(contacts)
    contacts.map{ |c|
      current_actor.blank? || c.sender == current_actor ?
        c :
        current_actor.contact_to!(c.receiver)
    }
  end

  private

  def exclude_reflexive
    if @contact.reflexive?
      redirect_to home_path
    end
  end

  def total_contacts
    @total_contacts ||=
      Contact.sent_by(current_subject).
              joins(:receiver).merge(Actor.alphabetic).
              positive.
              select("actors.name")
  end
end
