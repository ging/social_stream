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

  describe 'files' do
    it "should render" do
      get :index, section: :files

      response.should be_success
    end
  end

end
