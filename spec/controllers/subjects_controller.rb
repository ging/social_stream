require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SubjectsController do
  render_views

  it "should redirect lrdd" do
    @user = Factory(:user)

    get :lrdd, :id => "#{ @user.slug }@test.host"

    response.should redirect_to(user_path(@user, :format => :xrd))
  end
end

