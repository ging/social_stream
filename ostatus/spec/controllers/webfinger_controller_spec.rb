require 'spec_helper'

describe WebfingerController do
  before do
    @user = Factory(:user)
  end

  it "should render index" do
    get :index, q: @user.webfinger_id

    response.should be_success
  end
end
