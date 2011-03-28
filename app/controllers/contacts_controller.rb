class ContactsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @contacts = current_subject.contacts(:direction => :sent)

    respond_to do |format|
      format.html #index.html.erb
      format.json { render :text => @contacts.map{ |c| { 'key' => c.name, 'value' => c.actor_id.to_s } }.to_json }
    end
  end
end
