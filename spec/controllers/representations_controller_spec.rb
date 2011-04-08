require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RepresentationsController do
  include ActionController::RecordIdentifier

  describe "create" do
    context "with logged user" do
      before do
        @user = Factory(:user)
        sign_in @user
      end

      context "representing herself" do
        it "should redirect_to root" do
          post :create, :representation => { :subject_dom_id => dom_id(@user) }

          response.should redirect_to(:root)
        end
      end

      context "representing own group" do
        before do
          @group = Factory(:member, :receiver => @user.actor).sender_subject
        end

        it "should redirect_to root" do
          post :create, :representation => { :subject_dom_id => dom_id(@group) }

          response.should redirect_to(:root)
        end
      end

      context "representing other group" do
        before do
          @group = Factory(:group)
        end

        it "should deny access" do
          begin
            post :create, :representation => { :subject_dom_id => dom_id(@group) }

            assert false
          rescue CanCan::AccessDenied
            assert true
          end
        end
      end
    end
  end
end

