require 'spec_helper'

describe ActivitiesController do
  describe "show" do
    it "should redirecto to activity object" do
      id = 3
      activity = double("activity")
      post = Factory(:post)

      activity.should_receive(:direct_object) { post }

      Activity.should_receive(:find).with(id.to_s) { activity }

      get :show, id: id
    end
  end
end

