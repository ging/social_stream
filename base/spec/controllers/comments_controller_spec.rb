require 'spec_helper'

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
        activity = Factory(:self_activity, :contact => Factory(:self_contact, :sender => @user.actor))
        contact = @user.contact_to!(@user)

        model_attributes[:_contact_id] = contact.id
        model_attributes[:_activity_parent_id] = activity.id
      end

      it_should_behave_like "Allow Creating"

      it "should create with js" do
        count = model_count
        post :create, attributes.merge(:format => :js)

        resource = assigns(model_sym)

        model_count.should eq(count + 1)
        resource.should be_valid
        response.should be_success
      end
    end

    describe "comment to friend" do
      before do
        f = Factory(:friend, :contact => Factory(:contact, :receiver => @user.actor)).sender
        activity = Factory(:self_activity, :contact => f.contact_to!(f))
        contact = @user.contact_to!(f)

        model_attributes[:_contact_id] = contact.id
        model_attributes[:_activity_parent_id] = activity.id
      end

      it_should_behave_like "Allow Creating"
    end

    describe "post to acquaintance" do
      before do
        a = Factory(:acquaintance, :contact => Factory(:contact, :receiver => @user.actor)).sender
        activity = Factory(:self_activity, :contact => a.contact_to!(a))
        contact = @user.contact_to!(a)

        model_attributes[:_contact_id] = contact.id
        model_attributes[:_activity_parent_id] = activity.id
      end

      it_should_behave_like "Deny Creating"
    end
  end
end
