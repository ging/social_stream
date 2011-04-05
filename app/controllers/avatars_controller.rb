class AvatarsController < InheritedResources::Base

  before_filter :authenticate_user!
  def update

    if !current_subject.avatars.blank?

      new_logo = Avatar.find(params[:id])

      if (new_logo.actor == current_subject.actor)

        actual_logo = current_subject.avatars.active.first
        if !actual_logo.blank?
        actual_logo.active = false
        actual_logo.save
        end

      new_logo.active = true
      new_logo.save
      end
    end
    redirect_to avatars_path
  end

  def create
    @avatar = Avatar.create(params[:avatar])

    if @avatar.new_record?
      render :new
    else
      @avatar.updating_logo = true
      @avatar.actor_id = current_subject.actor.id
      if !current_subject.avatars.blank?
        actual_logo = current_subject.avatars.active.first
      actual_logo.active = false
      actual_logo.save
      end
      @avatar.active = true
      @avatar.save
      redirect_to avatars_path
    #redirect_to [current_subject, :profile]
    end
  end

  protected

  def begin_of_association_chain
    current_subject
  end

end
