require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  it "should find by slug" do
    user = Factory(:user)

    assert user.should == User.find_by_slug(user.slug)
  end

  it "should represent" do
    tie =   Factory(:member)
    group = tie.sender_subject
    user =  tie.receiver_subject

    assert user.represented.should include(group)

    tie = Factory(:partner, :receiver => user.actor)

    assert ! user.represented.include?(tie.sender_subject)
  end

  it "should have activity object" do
    Factory(:user).activity_object.should be_present
  end
end

