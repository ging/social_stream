require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tie do
  it "should find the relation by its name" do
    relation = Relation.first
    sender = Factory(relation.sender_type.underscore)
    receiver = Factory(relation.receiver_type.underscore)

    tie = Factory(:tie, :sender_id => sender.actor.id,
                        :receiver_id => receiver.actor.id,
                        :relation_name => relation.name)
    tie.should be_valid
  end

  describe "with a relation with inverse" do
    before do
      @relation = Relation.where("inverse_id IS NOT NULL").first
    end

    it "should have its inverse tie" do
      @tie = Factory(:tie, :relation => @relation)

      assert Tie.find_by_sender_id_and_receiver_id_and_relation_id(@tie.receiver_id,
                                                                   @tie.sender_id,
                                                                   @relation.inverse).present?
    end
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

    describe ", friend request" do
      before do
        @s = Factory(:friend_request, :receiver => @tie.receiver).sender
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
        Tie.allowing(@s, 'read', 'activity').should_not include(@tie.inverse)
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

