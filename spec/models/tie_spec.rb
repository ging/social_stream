require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tie do
  context "between 2 users" do
    before do
      @sender, @receiver = 2.times.map{ Factory(:user) }
    end

    it "should be created from relation name" do
      relation = @sender.relations.first

      tie = Tie.create(:sender_id => @sender.actor_id,
                       :receiver_id => @receiver.actor_id,
                       :relation_name => relation.name)

      tie.should_not be_new_record
    end

    it "should be created from relation_name and permissions" do
      tie = Tie.create :sender_id => @sender.actor_id,
                       :receiver_id => @receiver.actor_id,
                       :relation_name => "new relation",
                       :relation_permissions => [ Permission.first.id, Permission.last.id ]

      puts tie.errors
      tie.should_not be_new_record
      tie.relation.should_not be_new_record
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
        Tie.allowing(@s, 'create', 'activity').should_not include(@tie.related('public'))
      end

      it "reads activity" do
        Tie.allowing(@s, 'read', 'activity').should include(@tie)
        Tie.allowing(@s, 'read', 'activity').should include(@tie.related('public'))
      end
    end

    describe ", friend" do
      before do
        @s = Factory(:friend, :sender => @tie.sender).receiver
      end

      it "creates activity" do
        Tie.allowing(@s, 'create', 'activity').should_not include(@tie)
        Tie.allowing(@s, 'create', 'activity').should_not include(@tie.related('public'))
      end

      it "reads activity" do
        Tie.allowing(@s, 'read', 'activity').should include(@tie)
        Tie.allowing(@s, 'read', 'activity').should include(@tie.related('public'))
      end
    end

    describe ", acquaintance" do
      before do
        @s = Factory(:acquaintance, :receiver => @tie.receiver).sender
      end

      it "creates activity" do
        Tie.allowing(@s, 'create', 'activity').should_not include(@tie)
        Tie.allowing(@s, 'create', 'activity').should_not include(@tie.related('public'))
      end

      it "reads activity" do
        Tie.allowing(@s, 'read', 'activity').should_not include(@tie)
#        Tie.allowing(@s, 'read', 'activity').should_not include(@tie.related('public'))
      end
    end

    describe ", alien" do
      before do
        @s = Factory(:user)
      end

      it "creates activity" do
        Tie.allowing(@s, 'create', 'activity').should_not include(@tie)
        Tie.allowing(@s, 'create', 'activity').should_not include(@tie.related('public'))
      end
      
      it "reads activity" do
        Tie.allowing(@s, 'read', 'activity').should_not include(@tie)
        Tie.allowing(@s, 'read', 'activity').should     include(@tie.related('public'))
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
        Tie.allowing(@s, 'update', 'activity').should include(@tie.related('public'))
      end
    end

    describe ", member" do
      before do
        @s = Factory(:member, :sender => @tie.sender).receiver
      end

      it "creates activity" do
        Tie.allowing(@s, 'create', 'activity').should_not include(@tie)
        Tie.allowing(@s, 'create', 'activity').should_not include(@tie.related('public'))
      end

       it "reads activity" do
        Tie.allowing(@s, 'read', 'activity').should include(@tie)
        Tie.allowing(@s, 'read', 'activity').should include(@tie.related('public'))
      end

      it "updates activity" do
        Tie.allowing(@s, 'update', 'activity').should include(@tie)
        Tie.allowing(@s, 'update', 'activity').should include(@tie.related('public'))
      end
    end
  end
end

