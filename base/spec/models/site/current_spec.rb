require 'spec_helper'

describe Site::Current do
  it "should save configuration" do
    Site::Current.instance.config[:test] = "test"

    Site::Current.instance.save!

    Site::Current.instance_variable_defined?("@instance").should be_true

    Site::Current.instance_variable_set "@current", nil

    Site::Current.instance.config[:test].should eq("test")
  end

end
