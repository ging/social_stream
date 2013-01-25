require 'spec_helper'

describe Site::Client do
  it "should be created with url" do
    site = Site::Client.create name: "Test",
                               url: "http://test.com",
                               callback_url: "http://test.com/callback"

    site.should be_valid
  end
end
