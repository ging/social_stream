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
    Ability.new(@user).should be_able_to(:update, @client)
  end

  it "should not allow update to other" do
    Ability.new(Factory(:user)).should_not be_able_to(:update, @client)
  end
end
