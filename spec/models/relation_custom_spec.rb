require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Relation::Custom do
  it "should assign parent" do
    parent = Factory(:relation_custom)
    sphere = parent.sphere

    r = Relation::Custom.create! :name => "test",
                                 :sphere_id => sphere.id

    r.parent.should eq(parent)
  end
end

