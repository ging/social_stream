class TiesController < ApplicationController
  respond_to :html

  before_filter :authenticate_user!

  def index
    unless current_subject.sent_contacts.active.count > 0
      flash[:notice] = t('contact.graph.empty')
    end
  end
end
