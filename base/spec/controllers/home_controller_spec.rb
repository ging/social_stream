require 'spec_helper'

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
      @user = Factory(:user)
      sign_in @user
    end

    it "should render" do
      get :index

      response.should be_success
      response.body.should =~ /new_post/
    end

    context "with a group" do
      before do
        Factory(:friend,
                :contact => Factory(:g2g_contact, :sender => @user.actor))
      end

      it "should render" do
        get :index

        response.should be_success
        response.body.should =~ /new_post/
      end
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

