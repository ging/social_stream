require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  render_views

  describe "when Anonymous" do
    it "should render index" do
      get :index

      assert_response :success
    end

    it "should render show" do
      get :show, :id => Factory(:friend, :receiver => Factory(:group).actor).sender_subject.to_param

      assert_response :success
    end

    it "should not render edit" do
      begin
        get :edit, :id => Factory(:user).to_param

        assert false
      rescue CanCan::AccessDenied 
        assert true
      end
    end
  end

  describe "when authenticated" do
    before do
      @user = Factory(:friend, :receiver => Factory(:group).actor).sender_subject

      sign_in @user
    end

    it "should render index" do
      get :index

      assert_response :success
    end

    it "should render self page" do
      get :show, :id => @user.to_param

      assert_response :success
    end

    it "should render other's page" do
      get :show, :id => Factory(:user).to_param

      assert_response :success
    end

    it "should render other's page with activity" do
      tie = Factory(:friend, :receiver => @user.actor)
      friend = tie.sender
      Factory(:post, :_activity_tie_id => @user.activity_ties_to(friend).first)

      get :show, :id => friend.to_param

      response.should be_success
    end

    it "should render edit page" do
      pending "Account section"
      get :edit, :id => @user.to_param

      assert_response :success
    end

    it "should not render other's edit" do
      begin
        get :edit, :id => Factory(:user).to_param

        assert false
      rescue CanCan::AccessDenied 
        assert true
      end
    end

  end
end

