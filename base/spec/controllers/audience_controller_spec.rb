require 'spec_helper'

describe AudienceController do
  include SocialStream::TestHelpers
  include SocialStream::TestHelpers::Controllers

  render_views

  context "with activity" do
    before :all do
      @activity = Factory(:activity)
    end

    it "should not be redered to public" do
      get :index, :activity_id => @activity.id, :format => :js

      response.should redirect_to(:new_user_session)
    end

    it "should not be rendered to anyone" do
      sign_in Factory(:user)

      begin
        get :index, :activity_id => @activity.id, :format => :js

        assert false
      rescue CanCan::AccessDenied
        assert true
      end
    end

    it "should not be rendered to author" do
      sign_in @activity.author_subject

      get :index, :activity_id => @activity.id, :format => :js

      response.should be_success
    end
  end
end
