class AdministratorsController < ApplicationController
  def index
    authorize! :update, Site.current
  end
end
