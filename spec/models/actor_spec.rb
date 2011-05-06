require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Actor do
  it "should generate slug" do
    assert Factory(:actor).slug.present?
  end

  it "should generate different slug" do
    a = Factory(:actor)
    b = Factory(:actor, :name => a.name)

    a.name.should == b.name
    a.slug.should_not == b.slug
  end

  it "should generate relations" do
    assert Factory(:actor).relation_customs.present?
  end
end
