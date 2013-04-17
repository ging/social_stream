require 'spec_helper'

describe EventsController do
  render_views

  context "public calendar" do
    context "when Anonymous" do
      it "should render index" do
        get :index

        response.should redirect_to(new_user_session_path)
      end
    end
  end

  context "user's calendar" do
    before do
      @user = Factory(:user)
    end

    describe "when Anonymous" do
      it "should render to login" do
        get :index, user_id: @user.to_param

        response.should be_success
      end
    end
  end
end

