class FrontpageController < ApplicationController
  before_filter :redirect_user_to_home, :only => :index

  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # Webfinger protocol
  # http://code.google.com/p/webfinger/
  def host_meta
  end
  

  private

  def redirect_user_to_home
    redirect_to(home_path) if user_signed_in?
  end

end

