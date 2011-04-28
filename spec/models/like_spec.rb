require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Like do

  describe "activity" do
    before do
      @like_activity = Factory(:like_activity)
      @activity = @like_activity.parent
    end

    it "should recognize the user who likes it" do
      assert @activity.liked_by?(@like_activity.sender)
    end

    it "should not recognize the user who does not like it" do
      assert ! @activity.liked_by?(Factory(:user))
    end
  end

  describe "actor" do
    shared_examples_for "creates activity" do
      it "should recognize the user who likes it" do
        Like.build(@sender, @receiver).save

        assert @receiver.liked_by?(@sender)
      end

      it "should increment like count" do
        count = @receiver.like_count

        Like.build(@sender, @receiver).save

        @receiver.like_count.should eq(count + 1)
      end

      it "should decrement like count" do
        @like = Like.build(@sender, @receiver)
        @like.save

        count = @receiver.like_count

        @like.destroy

        @receiver.like_count.should eq(count - 1)
      end
    end

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
end


