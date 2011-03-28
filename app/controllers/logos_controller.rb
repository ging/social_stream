class LogosController < InheritedResources::Base
=begin  
  def new
#    if params[:logo_logo].present?
 #    render :template => "logos/_precrop", :layout => false
  #  end
    debugger
    if params[:logo_logo]
      
    end
     respond_to do |format|
      format.html #new.html.erb
     end
 
  end
=end
begin  
def create
    @logo = Logo.create(params[:logo])
    
    
    if @logo.new_record?
      render :new
    else
      #debugger
      @logo.updating_logo = true
      @logo.actor_id = current_subject.id
      current_subject.logo.destroy
      @logo.save     
      redirect_to logos_path
    end
    
    
    
    
  end
end  
  
end
