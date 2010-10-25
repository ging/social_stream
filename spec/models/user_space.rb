require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  it "should find by permalink" do
    user = Factory(:user)

    assert user.should == User.find_by_permalink(user.permalink)
  end
end

