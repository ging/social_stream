require 'spec_helper'

describe Site::Client do
  before do
    @user = Factory(:user)

    @client = Site::Client.create name: "Test",
                                  url: "http://test.com",
                                  callback_url: "http://test.com/callback",
                                  author: @user
  end

  it "should allow update to author" do
    assert @client.allow? @user, 'update'
  end

  it "should not allow update to other" do
    assert !@client.allow?(Factory(:user), 'update')
  end
end
