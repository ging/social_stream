class TiesController < ApplicationController
  before_filter :actor!

  # GET /ties
  # GET /ties.xml
  def index
    @ties = actor.sent_ties.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ties }
    end
  end

  # GET /ties/1
  # GET /ties/1.xml
  def show
    @tie = actor.sent_ties.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tie }
    end
  end

  # GET /ties/new
  # GET /ties/new.xml
  def new
    @tie = actor!.sent_ties.build(params[:tie])

    respond_to do |format|
      format.html {render :layout => false  }
      #format.xml  { render :xml => @tie }
      format.js {render :partial => "ties/new"}
    end
  end

  # POST /ties
  # POST /ties.xml
  def create
    @tie = Tie.new(params[:tie])

    respond_to do |format|
      if @tie.save
        format.html { redirect_to(@tie, :notice => 'Tie was successfully created.') }
        format.xml  { render :xml => @tie, :status => :created, :location => @tie }
        format.js
      else
        format.html { render :partial => "new" }
        format.xml  { render :xml => @tie.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /ties/1
  # DELETE /ties/1.xml
  def destroy
    @tie = Tie.find(params[:id])
    @tie.destroy

    respond_to do |format|
      format.html { redirect_to(ties_url) }
      format.xml  { head :ok }
    end
  end

  private
  
  def actor!
    current_user
  end
end
