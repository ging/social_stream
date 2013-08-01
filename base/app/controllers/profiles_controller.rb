class ProfilesController < ApplicationController
  before_filter :authenticate_user!, :except => [ :show ]

  before_filter :authorize_update, except: [ :show ]

  respond_to :html, :js

  def show
    subject_profile

    respond_to do |format|
      format.html
      format.js
      format.json { render json: subject_profile.to_json }
    end
  end

  def edit
  end

  def update
    subject_profile.update_attributes profile_params

    respond_to do |format|
      format.html{ redirect_to [profile_subject, :profile] }
      format.js
    end
  end

  private

  def profile_params
    params.
      require(:profile).
      permit(:name, :organization, :birthday, :city, :country, :description,
             :phone, :mobile, :fax, :email, :address, :website,
             :experience,
             :tag_list)
  end

  def subject_profile
    @profile ||=
      profile_or_current_subject!.profile
  end

  def current_profile
    @profile ||= find_current_profile
  end

  def find_current_profile
    unless profile_subject!.represented_by?(current_subject) 
      raise CanCan::AccessDenied
    end

    current_subject.profile
  end

  def authorize_update
    authorize! :update, subject_profile
  end
end
