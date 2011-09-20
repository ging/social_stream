require 'spec_helper'

describe Tie do
  describe "follower_count" do
    it "should be incremented" do
      sender, receiver = 2.times.map{ Factory(:user) }

      count = receiver.follower_count

      follower_relation = sender.
                          relation_customs.
                          joins(:permissions).
                          merge(Permission.follow).
                          first

      Tie.create :contact_id => sender.contact_to!(receiver).id,
                 :relation_id => follower_relation.id

      receiver.reload.follower_count.should eq(count + 1)
    end
    
    it "should be decremented" do
      tie = Factory(:friend)
      contact = tie.contact
      receiver = tie.receiver
      count = receiver.follower_count

      contact.reload.relation_ids = []

      receiver.reload.follower_count.should eq(count - 1)
    end
  end

  describe "friend" do
    before do
      @tie = Factory(:friend)
    end

    it "should create pending" do
      @tie.receiver.received_contacts.pending.should be_present
    end

    it "should create activity with follow verb" do
      @tie.contact.activities.should be_present
      @tie.contact.activities.first.verb.should eq('follow')
    end

    context "reciprocal" do
      before do
        @reciprocal = Factory(:friend, :contact => @tie.contact.inverse!)
      end

      it "should create activity with make-friend verb" do
        @reciprocal.contact.activities.should be_present
        @reciprocal.contact.activities.first.verb.should eq('make-friend')
      end
    end

  end

  describe "with public relation" do
    it "should create activity" do
      count = Activity.count

      Factory(:public)

      Activity.count.should eq(count + 1)
    end
  end

  describe "with reject relation" do
    it "should not create activity" do
      count = Activity.count

      Factory(:reject)

      Activity.count.should eq(count)
    end
  end

end

