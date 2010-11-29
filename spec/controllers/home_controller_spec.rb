require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do
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
      assert_response :success
    end
  end
end

