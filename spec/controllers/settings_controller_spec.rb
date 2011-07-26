require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')



describe SettingsController do
  include SocialStream::TestHelpers
  render_views

  it "should render index" do
    get :index
    assert_response :success
  end

  it "should render index after update_all" do
    put :update_all
    response.should redirect_to settings_path
  end

describe "Notification settings" do
    before do
      @user = Factory(:user)
      @actor = @user.actor
      sign_in @user
    end

    it "update notification email settings to Never" do
      @actor.update_attribute(:notify_by_email, true)
      assert @actor.notify_by_email.should
      put :update_all, :settings_section => "notifications", :notify_by_email => "never"
      response.should redirect_to settings_path
      assert ! @actor.notify_by_email.should

    end

    it "update notification email settings to Always" do
      @actor.update_attribute(:notify_by_email, false)
      assert ! @actor.notify_by_email.should
      put :update_all, :settings_section => "notifications", :notify_by_email => "always"
      response.should redirect_to settings_path
      assert @actor.notify_by_email.should
    end
  end
end