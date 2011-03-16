require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupsController do
  render_views

  describe "when Anonymous" do
    it "should render index" do
      get :index

      assert_response :success
    end

    it "should render show" do
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

    it "should render contact group" do
      @group = Factory(:member, :receiver => @user.actor).sender_subject
      get :show, :id => @group.to_param

      assert_response :success
    end

    it "should render other group" do
      get :show, :id => Factory(:group).to_param

      assert_response :success
    end

    it "should update contact group" do
      @group = Factory(:member, :receiver => @user.actor).sender_subject
      put :update, :id => @group.to_param,
                   "group" => { "profile_attributes" => { "organization" => "Social Stream" } }

      response.should redirect_to(@group)
    end
  end
end

