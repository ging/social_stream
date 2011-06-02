require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FrontpageController do
  render_views

  it "should render index" do
    get :index
    assert_response :success
  end
end

