require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Actor do
  it "should generate slug" do
    assert Factory(:user).actor.slug.present?
  end

  it "should generate different slug" do
    a = Factory(:user).actor
    b = Factory(:user, :name => a.name).actor

    a.name.should == b.name
    a.slug.should_not == b.slug
  end

  it "should generate relations" do
    assert Factory(:user).relation_customs.present?
  end

  context 'pending contacts' do
    it 'should not include self' do
      a = Factory(:user).actor
      c = a.contact_to!(a)

      a.pending_contacts.should_not include(c)
    end
  end
end
