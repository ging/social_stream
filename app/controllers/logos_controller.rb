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
    #debugger
    #{:original=>#<File:/var/folders/EZ/EZmst6HwE0ipKa3hozX2Zk+++TI/-Tmp-/stream20110322-5217-ft6j6l-0.jpg>}

    
    if @logo.new_record?
      render :new
    else
      #redirect_to @logo
      redirect_to logos_path
    end
    
    
    
    
  end
end  
  
end
