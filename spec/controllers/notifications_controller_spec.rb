require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NotificationsController do
  include SocialStream::TestHelpers
  render_views
  
  context "for a user" do
    before do
      @user = Factory(:user)
      sign_in @user
      @receipt = @user.notify("subject", "body")
    end
    
    it "should render index" do
      get :index
      assert_response :success
    end
    
    it "should render show" do
      get :show, :notification_id => @receipt.notification.to_param
      assert_response :success
    end
    
    it "should update" do
      put :update, :notification_id => @receipt.notification.to_param

      response.should redirect_to([@user, :profile])
    end

  end
  
  context "for a group" do
    before do
      membership = Factory(:member)
      @group = membership.sender_subject
      @user  = membership.receiver_subject

      sign_in @user
      represent @group
    end
    
    it "should render index" do
      get :index
      assert_response :success
    end
  end
end