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
        contact = @user.contact_to!(@user)
        relation = @user.relation_customs.sort.first

        model_assigned_to contact, relation
      end

      it_should_behave_like "Allow Creating"
    end

    describe "comment to friend" do
      before do
        f = Factory(:friend, :contact => Factory(:contact, :receiver => @user.actor)).sender
        contact = @user.contact_to!(f)
        relation = f.relation_custom('friend')

        model_assigned_to contact, relation
      end

      it_should_behave_like "Allow Creating"
    end

    describe "post to acquaintance" do
      before do
        a = Factory(:acquaintance, :contact => Factory(:contact, :receiver => @user.actor)).sender
        contact = @user.contact_to!(a)
        relation = a.relation_custom('acquaintance')

        model_assigned_to contact, relation
      end

      it_should_behave_like "Deny Creating"
    end
  end
end
