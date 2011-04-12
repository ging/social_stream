class ContactsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @contacts =
      current_subject.
        contacts(:direction => :sent){ |q|
          q.alphabetic.
            letter(params[:letter]).
            search(params[:search]).
            merge(Tie.related_by(current_subject.relations.find_by_id(params[:relation])))
        }

    respond_to do |format|
      format.html { @contacts = @contacts.paginate(:page => params[:page], :per_page => 10) }
      format.js { @contacts = @contacts.paginate(:page => params[:page], :per_page => 10) }
      format.json { render :text => @contacts.map{ |c| { 'key' => c.name, 'value' => c.actor_id.to_s } }.to_json }
    end
  end
end
