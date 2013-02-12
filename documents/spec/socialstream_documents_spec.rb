require 'spec_helper'

describe SocialStream::Documents do
  it "should be valid" do
    SocialStream::Documents.should be_a(Module)
  end

  describe "subtypes" do
    it "should return expected value" do
      SocialStream::Documents.subtypes.should eq([ :picture, :audio, :video ])
    end
  end
end
