require 'spec_helper'

describe HostMetaController do
  render_views

  it "should render host_meta" do
    get :index, :format => :all
    assert_response :success
  end
end
