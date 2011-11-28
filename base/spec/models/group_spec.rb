require 'spec_helper'

describe Group do
  it "should save description" do
    user = Factory(:user)

    g = Group.create :name => "Test",
                     :description => "Testing description",
                     :author_id => user.actor.id,
                     :user_author_id => user.actor.id

    g.reload.description.should be_present
  end

  it "should have activity_object" do
    Factory(:group).activity_object.should be_present
  end

  it "should save tag list" do
    g = Factory(:group)

    g.tag_list = "bla, ble"
    g.save!

    g.reload.tag_list.should be_present
  end
end

