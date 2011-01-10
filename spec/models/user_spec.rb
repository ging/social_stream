require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  it "should find by permalink" do
    user = Factory(:user)

    assert user.should == User.find_by_permalink(user.permalink)
  end

  it "should represent" do
    tie =   Factory(:member)
    group = tie.sender_subject
    user =  tie.receiver_subject

    assert user.represented.should include(group)

    tie = Factory(:partner, :receiver => user.actor)

    assert user.represented.should_not include(tie.sender_subject)
  end
end

