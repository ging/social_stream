require 'spec_helper'

describe ActivityAction do
  context "a following contact" do
    before do
      @tie = Factory(:friend)
    end

    it "should create follow action" do
      action = @tie.sender.action_to(@tie.receiver)

      action.should be_present
      action.should be_follow
    end

    it "should remove follow action" do
      action = @tie.sender.action_to(@tie.receiver)

      action.should be_present

      @tie.destroy

      action.reload.should_not be_follow
    end
  end
end
