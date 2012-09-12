require 'spec_helper'

describe SocialStream::ActivityStreams do
  it "should find by type" do
    SocialStream::ActivityStreams.model(:person).should == User
  end

  it "should return Post as default model" do
    SocialStream::ActivityStreams.model!(:_test).should == Post
  end

  it "should find by model" do
    SocialStream::ActivityStreams.type(User).should == :person
  end
end

