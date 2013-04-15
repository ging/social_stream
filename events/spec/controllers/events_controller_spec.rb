require 'spec_helper'

describe EventsController do
  render_views

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

