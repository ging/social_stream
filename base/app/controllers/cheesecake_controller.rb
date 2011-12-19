class CheesecakeController < ApplicationController
  
  before_filter :authenticate_user!
  
  def index
    @actors = current_subject.contact_actors(:direction => :sent)
  end
  
end
