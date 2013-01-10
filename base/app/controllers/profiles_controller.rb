class ProfilesController < ApplicationController
  before_filter :authenticate_user!, :except => [ :show ]

  respond_to :html, :js

  def show
    subject_profile
  end

  def edit
    current_profile
  end

  def update
    current_profile.update_attributes profile_params

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
      profile_subject!.profile
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
end
