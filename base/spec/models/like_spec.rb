require 'spec_helper'

describe Like do
  shared_examples_for "creates activity" do
    it "should recognize the user who likes it" do
      Like.build(@sender, @sender, @receiver).save

      assert @receiver.liked_by?(@sender)
    end

    it "should increment like count" do
      count = @receiver.like_count

      Like.build(@sender, @sender, @receiver).save

      @receiver.like_count.should eq(count + 1)
    end

    it "should decrement like count" do
      @like = Like.build(@sender, @sender, @receiver)
      @like.save

      count = @receiver.like_count

      @like.destroy

      @receiver.like_count.should eq(count - 1)
    end
  end

  describe "activity" do
    before do
      @like_activity = Factory(:like_activity)
      @activity = @like_activity.parent
      @sender = @like_activity.sender
      @receiver = @activity
    end

    it "should recognize the user who likes it" do
      assert @activity.liked_by?(@like_activity.sender)
    end

    it "should not recognize the user who does not like it" do
      assert ! @activity.liked_by?(Factory(:user))
    end
  end

  describe "actor" do

    context "friend" do
      before do
        tie = Factory(:friend)
        @sender = tie.sender
        @receiver = tie.receiver
      end

      it_should_behave_like "creates activity"
    end

    context "alien" do
      before do
        @sender, @receiver = 2.times.map{ Factory(:user) }
      end

      it_should_behave_like "creates activity"
    end
  end

  describe "post" do
    before do
      @receiver = Factory(:post)
      @sender = Factory(:user)
    end

    it_should_behave_like "creates activity"
  end

  describe "comment" do
    before do
      @receiver = Factory(:comment)
      @sender = Factory(:user)
    end

    it_should_behave_like "creates activity"
  end
end


