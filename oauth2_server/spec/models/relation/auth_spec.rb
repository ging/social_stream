require 'spec_helper'

describe User do
  let(:user) { Factory(:user) }
  let(:client) { Factory(:site_client) }

  describe "client_authorize!" do
    it "should create tie" do
      user.client_authorize!(client)

      user.reload.sent_ties.count.should be > 0
    end
  end
end

