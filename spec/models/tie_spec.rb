require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tie do
  it "should create from relation name" do
    relation = Relation.first
    sender = Factory(relation.sender_type.underscore)

    receiver_type = relation.receiver_type.present? ?
                      relation.receiver_type :
                      relation.sender_type
                   
    receiver = Factory(receiver_type.underscore)

    tie = Factory(:tie, :sender_id => sender.actor.id,
                        :receiver_id => receiver.actor.id,
                        :relation_name => relation.name)
    tie.should be_valid
  end

  it "should create pending" do
    tie = Factory(:friend)

    assert tie.receiver.pending_ties.present?
    assert tie.receiver.pending_ties.first.relation_set.blank?
  end

  describe "friend" do
    before do
      @tie = Factory(:friend)
    end

    describe ", receiver" do
      before do
        @s = @tie.receiver
      end

      it "creates activity" do
        Tie.allowing(@s, 'create', 'activity').should include(@tie)
        Tie.allowing(@s, 'create', 'activity').should include(@tie.related('public'))
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

