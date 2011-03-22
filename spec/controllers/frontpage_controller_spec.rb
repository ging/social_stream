require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FrontpageController do
  render_views

  it "should render index" do
    get :index
    assert_response :success
  end

  it "should render host_meta" do
    get :host_meta, :format => :all
    assert_response :success
  end
end

