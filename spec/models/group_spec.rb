require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Group do
  it "should save description" do
    g = Group.create(:name => "Test",
                     :description => "Testing description",
                     :_founder => Factory(:user).slug)

    g.reload.description.should be_present
  end
end

