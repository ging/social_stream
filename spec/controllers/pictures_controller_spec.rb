require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PicturesController do
  render_views

  context "with public picture" do
    before do
      @picture = Factory(:public_picture)
    end

    it "should render index" do
      get :index, :user_id => @picture.post_activity.receiver.to_param

      response.should be_success
    end
  end
end
