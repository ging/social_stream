require 'spec_helper'

describe SocialStream::ActivityStreams do
  it "should find by type" do
    SocialStream::ActivityStreams.model('person').should == User
  end

  it "should find by model" do
    SocialStream::ActivityStreams.type(User).should == 'person'
  end
end

