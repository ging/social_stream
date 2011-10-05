require 'spec_helper'

describe InvitationsController do
  render_views

  context "without authentication" do
    it "should redirect to login" do
      get :new

      response.should redirect_to(new_user_session_path)
    end
  end

  context "authenticated" do
    before do
      @user = Factory(:user)

      sign_in @user
    end

    it "should render new" do
      get :new

      response.should be_success
    end

    it "should send invitation" do
      post :create, :mails => "test@test.com, bla@bla.com", :message => "Testing"

      response.should be_success

    end
  end
end
