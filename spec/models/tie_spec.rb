require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tie do
  context "between 2 users" do
    before do
      @sender, @receiver = 2.times.map{ Factory(:user) }
    end

    it "should be created from relation name" do
      relation = @sender.relation_customs.first

      tie = Tie.create :sender_id => @sender.actor_id,
                       :receiver_id => @receiver.actor_id,
                       :relation_name => relation.name

      tie.should_not be_new_record
    end

    it "should be created from relation_name and permissions" do
      pending "Redesign forms"

      tie = Tie.create :sender_id => @sender.actor_id,
                       :receiver_id => @receiver.actor_id,
                       :relation_name => "new relation",
                       :relation_permissions => [ Permission.first.id, Permission.last.id ]

      puts tie.errors
      tie.should_not be_new_record
      tie.relation.should_not be_new_record
    end
  end

  describe "follower_count" do
    it "should be incremented" do
      sender, receiver = 2.times.map{ Factory(:user) }

      count = receiver.follower_count

      Tie.create :sender_id => sender.actor_id,
                 :receiver_id => receiver.actor_id,
                 :relation_id => sender.relation_customs.sort.first.id

      receiver.reload.follower_count.should eq(count + 1)
    end
    
    it "should be decremented" do
      tie = Factory(:friend)
      receiver = tie.receiver
      count = receiver.follower_count

      tie.destroy

      receiver.reload.follower_count.should eq(count - 1)
    end
  end

  context "replied" do
    before do
      @sent = Factory(:friend)
      @received = Factory(:friend,
                         :sender_id => @sent.receiver_id,
                         :receiver_id => @sent.sender_id)
    end

    it "should be found by scopes" do
      Tie.replied.should include(@sent)
      Tie.replied.should include(@received)
      Tie.replying(@sent).should include(@received)
      Tie.replying(@received).should include(@sent)
    end
  end

  describe "friend" do
    before do
      @tie = Factory(:friend)
    end

    it "should create pending" do

      assert @tie.receiver.pending_ties.present?
      assert @tie.receiver.pending_ties.first.relation_set.blank?
    end

    it "should be following" do
      assert Tie.following(@tie.receiver_id).include?(@tie)
    end

    describe ", receiver" do
      before do
        @s = @tie.receiver
      end

      it "creates activity" do
        Tie.allowing(@s, 'create', 'activity').should include(@tie)
      end

      it "reads activity" do
        Tie.allowing(@s, 'read', 'activity').should include(@tie)
      end
    end

    describe ", friend" do
      before do
        @s = Factory(:friend, :sender => @tie.sender).receiver
      end

      it "creates activity" do
        Tie.allowing(@s, 'create', 'activity').should_not include(@tie)
      end

      it "reads activity" do
        Tie.allowing(@s, 'read', 'activity').should include(@tie)
      end
    end

    describe ", acquaintance" do
      before do
        @s = Factory(:acquaintance, :receiver => @tie.receiver).sender
      end

      it "creates activity" do
        Tie.allowing(@s, 'create', 'activity').should_not include(@tie)
      end

      it "reads activity" do
        Tie.allowing(@s, 'read', 'activity').should_not include(@tie)
      end
    end

    describe ", alien" do
      before do
        @s = Factory(:user)
      end

      it "creates activity" do
        Tie.allowing(@s, 'create', 'activity').should_not include(@tie)
      end
      
      it "reads activity" do
        Tie.allowing(@s, 'read', 'activity').should_not include(@tie)
      end
    end
  end

  describe "member" do
    before do
      @tie = Factory(:member)
    end

    describe ", receiver" do
      before do
        @s = @tie.receiver
      end

      it "updates activity" do
        Tie.allowing(@s, 'update', 'activity').should include(@tie)
      end
    end

    describe ", member" do
      before do
        @s = Factory(:member, :sender => @tie.sender).receiver
      end

      it "creates activity" do
        Tie.allowing(@s, 'create', 'activity').should_not include(@tie)
      end

       it "reads activity" do
        Tie.allowing(@s, 'read', 'activity').should include(@tie)
      end

      it "updates activity" do
        Tie.allowing(@s, 'update', 'activity').should_not include(@tie)
      end
    end
  end
end

