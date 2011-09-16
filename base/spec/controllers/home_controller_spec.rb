require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do
  include SocialStream::TestHelpers

  render_views

  describe "when Anonymous" do
    it "should redirect to login" do
      get :index
      response.should redirect_to(new_user_session_path)
    end
  end

  describe "when authenticated" do
    before do
      sign_in Factory(:user)
    end

    it "should render" do
      get :index

      response.should be_success
      response.body.should =~ /activities_share_btn/
    end

    describe "when representing" do
      before do
        @represented = represent(Factory(:group))
      end

      it "should render represented home" do
        get :index

        assert_response :success
        assigns(:current_subject).should == @represented
      end
    end
  end
end

