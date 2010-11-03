class UsersController < ApplicationController

  def show
    @user = User.find_by_permalink!(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end
end
