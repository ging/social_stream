require 'spec_helper'

describe SettingsController do
  include SocialStream::TestHelpers
  render_views

  before do
    @user = Factory(:user)
    @actor = @user.actor
    sign_in @user
  end

  it "should render index" do
    get :index
    assert_response :success
  end

  it "should render index after update_all" do
    put :update_all
    response.should redirect_to settings_path
  end

  describe "Notification settings" do
    it "update notification email settings to Never" do
      @actor.update_attributes(:notify_by_email => true)
      @actor.notify_by_email.should==true
      put :update_all, :settings_section => "notifications", :notify_by_email => "never"
      @actor.reload
      @actor.notify_by_email.should==false

    end

    it "update notification email settings to Always" do
      @actor.update_attributes(:notify_by_email => false)
      @actor.notify_by_email.should==false
      put :update_all, :settings_section => "notifications", :notify_by_email => "always"
      @actor.reload
      @actor.notify_by_email.should==true
    end
  end
end
