require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TiesController do
  render_views

  describe "when authenticated" do
    before do
      @user = Factory(:user)

      sign_in @user
    end

    it "should render new" do
      get :new, :tie => Factory.attributes_for(:friend, :sender => @user.actor)

      assert_response :success
    end
  end
end
