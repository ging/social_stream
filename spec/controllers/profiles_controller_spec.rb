require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfilesController do
  render_views

  context "for a user" do
    before do
      @user = Factory(:user)
    end

    it "should render show" do
      get :show, :user_id => @user.to_param

      assert_response :success
    end

    it "should render edit" do
      pending

      get :edit, :user_id => @user.to_param

      assert_response :success
    end
  end

  context "for a group" do
    before do
      @group = Factory(:group)
    end

    it "should render show" do
      get :show, :group_id => @group.to_param

      assert_response :success
    end

    it "should render edit" do
      pending

      get :edit, :group_id => @group.to_param

      assert_response :success
    end
  end
end

