require 'spec_helper'

describe Site do
  it "should access configuration" do
    Site.current.config[:test] = "test"

    Site.current.config[:test].should eq("test")
  end

  it "should save configuration" do
    Site.current.config[:test] = "test"

    Site.current.save!

    Site.instance_variable_defined?("@current").should be_true

    Site.instance_variable_set "@current", nil

    Site.current.config[:test].should eq("test")
  end
end
