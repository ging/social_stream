require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe PostsController do
  include SocialStream::TestHelpers::Controllers

  render_views

  describe "authorizing" do
    before do
      @user = Factory(:user)
      sign_in @user
    end

    describe "posts to user" do
      before do
        model_assigned_to @user.sent_ties.received_by(@user).related_by(@user.relations.sort.first).first
      end

      it_should_behave_like "Allow Creating"
    end

    describe "post to friend" do
      before do
        model_assigned_to Factory(:friend, :receiver => @user.actor)
      end

      it_should_behave_like "Allow Creating"
    end

    describe "post to acquaintance" do
      before do
        model_assigned_to Factory(:acquaintance, :receiver => @user.actor)
      end

      it_should_behave_like "Deny Creating"
    end

  end
end

