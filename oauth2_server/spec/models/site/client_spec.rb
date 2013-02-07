require 'spec_helper'

describe Site::Client do
  before do
    @user = Factory(:user)

    @client = Site::Client.create name: "Test",
                                  url: "http://test.com",
                                  callback_url: "http://test.com/callback",
                                  author: @user


  end

  it "should be created with url" do
    @client.should be_valid
  end

  it "should establish tie to author" do
    @client.contact_to!(@user).relation_ids.should eq([Relation::Admin.instance.id])
  end
end
