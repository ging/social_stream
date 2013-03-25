require 'spec_helper'

describe ExploreController do
  render_views

  describe 'explore' do
    it "should render" do
      get :index

      response.should be_success
    end
  end

  describe 'participants' do
    it "should render" do
      get :index, section: :participants

      response.should be_success
    end
  end

  describe 'resources' do
    it "should render" do
      get :index, section: :resources

      response.should be_success
    end
  end

  describe 'timeline' do
    before do
      Factory(:public_activity)
    end

    it "should render" do
      get :index, section: 'timeline'

      response.should be_success
    end
  end
end
