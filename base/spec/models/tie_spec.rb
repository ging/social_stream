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

      Tie.create! :contact_id => sender.contact_to!(receiver).id,
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
      activity = Activity.authored_by(@tie.sender).owned_by(@tie.receiver).first
      activity.should be_present
      activity.verb.should eq('follow')
    end

    context "reciprocal" do
      before do
        @reciprocal = Factory(:friend, :contact => @tie.contact.inverse!)
      end

      it "should create activity with make-friend verb" do
        activity = Activity.authored_by(@reciprocal.sender).owned_by(@reciprocal.receiver).first

        activity.should be_present
        activity.verb.should eq('make-friend')
      end
    end

  end

  describe "with public relation" do
    before do
      @tie = Factory(:public)
    end

    it "should create activity" do
      count = Activity.count

      Factory(:public)

      Activity.count.should eq(count + 1)
    end

    it "should be positive" do
      @tie.should be_positive
    end

    it "should not be positive replied" do
      @tie.should_not be_positive_replied
    end

    context "with public reply" do
      before do
        Factory(:public, :contact => @tie.contact.inverse!)

        # It should reload tie.contact again, as its inverse is now set
        @tie.reload
      end

      it "should be positive replied" do
        @tie.should be_positive_replied
      end

      it "should be bidirectional" do
        @tie.should be_bidirectional
      end
    end

    context "with reject reply" do
      before do
       Factory(:reject, :contact => @tie.contact.inverse!)

        # It should reload tie.contact again, as its inverse is now set
        @tie.reload
      end

      it "should not be positive replied" do
        @tie.should_not be_positive_replied
      end

      it "should not be bidirectional" do
        @tie.should_not be_bidirectional
      end
    end
  end

  describe "with reject relation" do
    before do
      @tie = Factory(:reject)
    end

    it "should not create activity" do
      count = Activity.count

      Factory(:reject)

      Activity.count.should eq(count)
    end

    it "should not be positive" do
      @tie.should_not be_positive
    end

    context "with public reply" do
      before do
        Factory(:public, :contact => @tie.contact.inverse!)

        # It should reload tie.contact again, as its inverse is now set
        @tie.reload
      end

      it "should be positive replied" do
        @tie.should be_positive_replied
      end

      it "should not be bidirectional" do
        @tie.should_not be_bidirectional
      end
    end

    context "with reject reply" do
      before do
       Factory(:reject, :contact => @tie.contact.inverse!)

        # It should reload tie.contact again, as its inverse is now set
        @tie.reload
      end

      it "should not be positive replied" do
        @tie.should_not be_positive_replied
      end

      it "should not be bidirectional" do
        @tie.should_not be_bidirectional
      end
    end
  end
end

