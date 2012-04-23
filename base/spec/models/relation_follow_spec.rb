require 'spec_helper'

describe Relation::Follow do
  it "should have permissions" do
    Relation::Follow.instance.permissions.should include(Permission.find_or_create_by_action_and_object('follow', nil))
  end
end

