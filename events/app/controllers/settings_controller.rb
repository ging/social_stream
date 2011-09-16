	class SettingsController < InheritedResources::Base

  respond_to :html, :js
  #before_filter :authenticate_user!
  def show

  end 

  def manage

#	@cs_ = Actor.joins('INNER JOIN contacts ON contacts.receiver_id = actors.id INNER JOIN ties ON ties.contact_id = contacts.id INNER JOIN relations ON relations.id = ties.relation_id').where(:subject_type => ['User', 'Group', 'Event'], :contacts=>{:sender_id => current_subject}, :relations=>{:type => 'Relation::Custom'}).page(params[:page]).per(10)

	@cs = current_subject.contact_subjects(:direction => :sent)
	@cs = Kaminari.paginate_array(@cs).page(params[:page]).per(10)
#	@cs_page = Paginator.new(self, cs.length, 10, 1)
#	@offset = 0
#	@cs= cs[offset..(offset + 10 -1)]

  end

  def delete_relation
   @receiver = Actor.find params[:id]
   logger.info "antes del each"       
   contact=Contact.where(["sender_id="+current_subject.id.to_s+" and receiver_id="+@receiver.id.to_s])
   logger.info "cs:"+current_subject.name+"receiver:"+@receiver.name
   tie_to_delete=contact.first.ties
   logger.info "antes del if"
   tie_x=tie_to_delete.first
	 if tie_x != nil      
    tie_x.destroy
   end
   	@cs = current_subject.contact_subjects(:direction => :sent)
	  @cs = Kaminari.paginate_array(@cs).page(params[:page]).per(10)
    respond_to do |format|
      format.js {render :layout => false}
    end
#   redirect_to "/settings/manage"   
  end

  def update_relation
     @receiver = Actor.find params[:id]
     relations = params['manage']
     logger.info "antes del each"
	    relations.each do |x,y|
                 relation_id = y 
	         contacto=Contact.where(["sender_id="+current_subject.id.to_s+" and receiver_id="+@receiver.id.to_s])
		    logger.info "cs:"+current_subject.name+"receiver:"+@receiver.name
	         tie_a_editar=contacto.first.ties
		    logger.info "antes del if"
	         tie_x=tie_a_editar.first
	       if tie_x != nil
		      logger.info "dentro del if"
		       tie_x.relation_id=relation_id
		       tie_x.save
		      logger.info "luego del save"
	       else 
		      logger.info "dentro del else"
		       nuevo_tie=Tie.new
		       nuevo_tie.contact_id=contacto.first.id
		       nuevo_tie.relation_id=relation_id 
		       nuevo_tie.save
	       end	     
	    end 
      respond_to do |format|
        format.js {render :layout => false}
      end      

#     redirect_to "/settings/manage"
  end
end
