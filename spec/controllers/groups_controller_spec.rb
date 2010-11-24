require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupsController do
  render_views

  describe "when Anonymous" do
    it "should render index" do
      pending

      get :index

      assert_response :success
    end

    it "should render show" do
      pending

      get :show, :id => Factory(:group).to_param

      assert_response :success
    end
  end

  describe "when authenticated" do
    before do
      @user = Factory(:user)

      sign_in @user
    end

    it "should render index" do
      get :index

      assert_response :success
    end

    it "should render member group" do
      @group = Factory(:member, :sender => @user.actor).receiver_subject
      get :show, :id => @group.to_param

      assert_response :success
    end

    it "should render other group" do
      get :show, :id => Factory(:group).to_param

      assert_response :success
    end
  end
end

