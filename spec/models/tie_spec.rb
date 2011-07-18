require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
  end

  describe "with public relation" do
    it "should not create activity" do
      count = Activity.count

      Factory(:public)

      Activity.count.should eq(count)
    end
  end
end

