require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommentsController do
  include SocialStream::TestHelpers::Controllers

  render_views

  describe "authorizing" do
    before do
      @user = Factory(:user)
      sign_in @user
    end

    describe "comment from user" do
      before do
        model_assigned_to @user.sent_ties.received_by(@user).related_by(@user.relations.sort.first).first
      end

      it_should_behave_like "Allow Creating"
    end

    describe "comment from friend" do
      before do
        model_assigned_to Factory(:friend, :receiver => @user.actor)
      end

      it_should_behave_like "Allow Creating"
    end

    describe "post from acquaintance" do
      before do
        model_assigned_to Factory(:acquaintance, :receiver => @user.actor)
      end

      it_should_behave_like "Deny Creating"
    end
  end
end
