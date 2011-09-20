require 'spec_helper'

describe PermissionsController do
  include SocialStream::TestHelpers::Controllers

  render_views

  describe "when authenticated" do
    before do
      @user = Factory(:user)

      sign_in @user
    end

    context "with an existing relation" do
      before do
        @relation = Factory(:relation_custom, :actor_id => @user.actor_id)
      end

      it "should render index" do
        get :index, :relation_id => @relation.id, :format => "js"

        response.should be_success
      end
    end

    context "a external relation" do
      before do
        @relation = Factory(:relation_custom)
      end

      it "should not render index" do
        begin
          get :index, :relation_id => @relation.id, :format => "js"

          assert false
        rescue CanCan::AccessDenied
          assigns(:permissions).should be_nil
        end
      end
    end
  end
end


