require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TieActivity do
  describe "for followers" do
    before do
      @tie = Factory(:friend)

      @tie_to_sender_friend   = Factory(:friend, :receiver => @tie.sender)
      @tie_to_receiver_friend = Factory(:friend, :receiver => @tie.receiver)
    end

    describe "of a public activity" do
      before do
        @a = Factory(:activity, :_tie => @tie.related(@tie.sender.relations.sort.last))
      end

      it "should be created" do
        assert @tie_to_sender_friend.activities.include?(@a)
        assert @tie_to_receiver_friend.activities.include?(@a)
      end
    end

    describe "of a friend activity" do
      before do
        @a = Factory(:activity, :_tie => @tie)
      end

      it "should not be created" do
        assert !@tie_to_sender_friend.activities.include?(@a)
        assert !@tie_to_receiver_friend.activities.include?(@a)
      end
    end

    describe "one of them being friend" do
      before do
        Factory(:friend, :sender => @tie.sender, :receiver => @tie_to_receiver_friend.sender)
      end

      describe "with a friend activity" do
        before do
          @a = Factory(:activity, :_tie => @tie)
        end

        it "should be created for the friend" do
          assert !@tie_to_sender_friend.activities.include?(@a)
          assert @tie_to_receiver_friend.activities.include?(@a)
        end
      end
    end
  end
end

