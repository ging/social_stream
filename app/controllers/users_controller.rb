class UsersController < ApplicationController
  def index
    if params[:search]
      @users = User.search("%"+params[:search]+"%").paginate(:per_page => 10, :page => params[:page])
    else
      if params[:letter] && params[:letter]!="undefined"
        @users = User.search(params[:letter]+"%").paginate(:per_page => 10, :page => params[:page])
      else
        @users = User.alphabetic.paginate(:per_page => 10, :page => params[:page])
      end
    end
  end

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
        #format.html { render :action => "edit", :notice => 'User was successfully updated.' }
        format.html { render :partial => "right_show", :notice => 'User was successfully updated.' }
        format.xml  { head :ok }
        format.js 
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

end
