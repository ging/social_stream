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

    describe "where posting to other owner" do
      before do
        @post = Factory(:post)
      end

      it "should not be duplicated" do
        @post.received_actions.count.should == 2
      end

      it "should initialize follower count" do
        @post.reload.follower_count.should == 2
      end
    end

    describe "where posting to self" do
      before do
        @post = Factory(:self_post)
      end

      it "should not be duplicated" do
        @post.received_actions.count.should == 1
      end

      it "should initialize follower count" do
        @post.reload.follower_count.should == 1
      end
    end

    describe "where building the post" do
      before do
        user = Factory(:user)
        @post = Post.new :text => "Testing",
                         :author => user,
                         :owner  => user,
                         :user_author => user
        @post.save!
      end

      it "should not be duplicated" do
        @post.received_actions.count.should == 1
      end
    end
  end
end
