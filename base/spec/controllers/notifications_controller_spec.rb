require 'spec_helper'


describe NotificationsController do
  include SocialStream::TestHelpers
  render_views

  before do
    @user = Factory(:user)
    @actor =  @user.actor
    sign_in @user
    @receipt = @user.notify("subject", "body", Factory(:activity))
  end

  it "should render index" do
    get :index
    assert_response :success
  end

  it "should update read" do
    put :update, :id => @receipt.notification.to_param, :read => "Read"
    @receipt.notification.is_unread?(@actor).should==false
    assert_response :success
  end

  it "should update unread" do
    put :update, :id => @receipt.notification.to_param, :read => "Unread"
    @receipt.notification.is_unread?(@actor).should==true
    assert_response :success
  end

  it "should update all" do
    @receipt2 = @user.notify("subject", "body", Factory(:activity))
    put :update_all
    @receipt.notification.is_unread?(@actor).should==false
    @receipt2.notification.is_unread?(@actor).should==false
    assert_response :success
  end
  
  it "should send to trash" do
    delete :destroy, :id => @receipt.notification.to_param
    @receipt.notification.is_trashed?(@actor).should==true
    assert_response :success
  end

end
