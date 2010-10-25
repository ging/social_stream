require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Actor do
  it "should generate permalink" do
    assert Factory(:actor).permalink.present?
  end

  it "should generate different permalink" do
    a = Factory(:actor)
    b = Factory(:actor, :name => a.name)

    a.name.should == b.name
    a.permalink.should_not == b.permalink
  end

end
