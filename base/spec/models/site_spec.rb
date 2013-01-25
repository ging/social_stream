require 'spec_helper'

describe Site do
  it "should access configuration" do
    Site.current.config[:test] = "test"

    Site.current.config[:test].should eq("test")
  end
end
