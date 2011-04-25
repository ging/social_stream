require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do
  include ActionController::RecordIdentifier
  include SocialStream::TestHelpers

  render_views

  describe "create" do
    context "with logged user" do
      before do
        @user = Factory(:user)
        sign_in @user
      end

      context "to represent herself" do
        it "should redirect_to root" do
          get :index, :s => @user.slug

          assigns(:current_subject).should == @user
          response.should be_success
        end
      end

      context "to represent own group" do
        before do
          @group = Factory(:member, :receiver => @user.actor).sender_subject
        end

        it "should redirect_to root" do
          get :index, :s => @group.slug

          assigns(:current_subject).should == @group
          response.should be_success
        end
      end

      context "representing own group" do
        before do
          @group = Factory(:member, :receiver => @user.actor).sender_subject
          represent @group
        end

        context "to represent herself" do
          it "should redirect_to root" do
            get :index, :s => @user.slug

            assigns(:current_subject).should == @user
            response.should be_success
          end
        end
      end

      context "to represent other group" do
        before do
          @group = Factory(:group)
        end

        it "should deny access" do
          begin
            get :index, :s => @group.slug

            assert false
          rescue ActionView::Template::Error => e
            assert e.message == "Not authorized!"
          rescue CanCan::AccessDenied
            assert true
          end
        end
      end
    end
  end
end

