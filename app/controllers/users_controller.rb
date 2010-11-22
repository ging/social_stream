class UsersController < ApplicationController

  def show
    @user = User.find_by_permalink!(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
	end

  def edit
    @user = User.find_by_permalink!(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  def update
    
    @user = User.find_by_permalink!(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        #format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.html { render :action => "edit", :notice => 'User was successfully updated.' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

end
