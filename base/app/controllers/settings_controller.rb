class SettingsController < ApplicationController
  
  before_filter :authenticate_user!
  
  def index
  end

  def update_all
    success = false

    #If no section selected, skips and gives error
    if params[:settings_section].present?
      section = params[:settings_section].to_s

      #Updating notifications settings
      if section.eql? "notifications"
        #Notify by email setting
        if params[:notify_by_email].present?
          notify_by_email = params[:notify_by_email].to_s
          current_subject.notify_by_email = false if notify_by_email.eql? "never"
          current_subject.notify_by_email = true if notify_by_email.eql? "always"
        end
      end

      #Here sections to add
      #if section.eql? "section_name"
      #   blah blah blah
      #end

      #Was everything ok?
      success = current_subject.save
    end

    #Flashing and redirecting
    if success
      flash[:success] = t('settings.success')
    else
      flash[:error] = t('settings.error')
    end
    redirect_to :action => :index
  end

end
