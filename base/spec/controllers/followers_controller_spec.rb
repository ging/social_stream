require 'spec_helper'

describe FollowersController do
  include SocialStream::TestHelpers::Controllers

  render_views

  describe "with followers" do
    before do
      @user = Factory(:user)

      @follow = Factory(:follow, :contact => Factory(:contact, :sender => @user.actor))

      sign_in @user
    end

    it "should render index" do
      get :index

      response.should be_success
    end

    describe "with post" do
      before do
        Factory(:self_post, :author_id => @user.actor_id)
      end

      it "should render index" do
        get :index

        response.should be_success
      end
    end
  end
end


