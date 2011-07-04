require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module ActivityTestHelper
  def create_activity(contact, relations)
    @activity = Factory(:activity,
                        :contact_id => contact.id,
                        :relation_ids => Array(Relation.normalize_id(relations)))

  end

  def create_ability_accessed_by(subject)
    @ability = Ability.new(subject)
  end

  def create_ability_accessed_by_related(tie_type)
    @tie = create_related_tie(tie_type)
    @related = @tie.receiver_subject
    @ability = Ability.new(@related)
  end

  def create_ability_accessed_publicly
    u = Factory(:user)
    @ability = Ability.new(u)
  end

  def create_related_tie(tie_type)
    Factory(tie_type, :contact => Factory(:contact, :sender => Actor.normalize(@subject)))
  end

  shared_examples_for "Allows Creating" do
    it "should allow create" do
      @ability.should be_able_to(:create, @activity)
    end
  end
  
  shared_examples_for "Allows Reading" do
    it "should allow read" do
      @ability.should be_able_to(:read, @activity)
    end
  end
  
  shared_examples_for "Allows Updating" do
    it "should allow update" do
      @ability.should be_able_to(:update, @activity)
    end
  end
  
  shared_examples_for "Allows Destroying" do
    it "should allow destroy" do
      @ability.should be_able_to(:destroy, @activity)
    end
  end

  shared_examples_for "Denies Creating" do
    it "should deny create" do
      @ability.should_not be_able_to(:create, @activity)
    end
  end
  
  shared_examples_for "Denies Reading" do
    it "should deny read" do
      @ability.should_not be_able_to(:read, @activity)
    end
  end
  
  shared_examples_for "Denies Updating" do
    it "should deny update" do
      @ability.should_not be_able_to(:update, @activity)
    end
  end
  
  shared_examples_for "Denies Destroying" do
    it "should deny destroy" do
      @ability.should_not be_able_to(:destroy, @activity)
    end
  end
  
end

describe Activity do
  include ActivityTestHelper

  describe "wall" do
    context "with a friend activity" do
      before do
        @activity = Factory(:activity)
      end

      describe "sender home" do
        it "should include activity" do
          @activity.sender.wall(:home).should include(@activity)
        end
      end

      describe "receiver home" do
        it "should include activity" do
          @activity.receiver.wall(:home).should include(@activity)
        end
      end

      describe "alien home" do
        it "should not include activity" do
          Factory(:user).wall(:home).should_not include(@activity)
        end
      end

      describe "friend's profile" do
        it "should not include activity" do
          friend = Factory(:friend, :contact => Factory(:contact, :sender => @activity.sender)).receiver
          friend.wall(:profile, :for => @activity.sender).should_not include(@activity)
        end
      end

      describe "sender profile" do
        context "for sender" do
          it "should include activity" do
            @activity.sender.wall(:profile, :for => @activity.sender).should include(@activity)
          end
        end

        context "for receiver" do
          it "should include activity" do
            @activity.sender.wall(:profile, :for => @activity.receiver).should include(@activity)
            @activity.sender.wall(:profile,
                                  :for => @activity.receiver,
                                  :relation => @activity.relations.first).should include(@activity)
          end
        end
      end
    end

    context "with a self friend activity" do
      before do
        @activity = Factory(:self_activity)
      end

      describe "friend's profile" do
        it "should not include activity" do
          friend = Factory(:friend, :contact => Factory(:contact, :sender => @activity.sender)).receiver
          friend.wall(:profile, :for => @activity.sender).should_not include(@activity)
        end
      end
    end

    context "with a public activity" do
      before do
        @activity = Factory(:public_activity)
      end

      describe "sender home" do
        it "should include activity" do
          @activity.sender.wall(:home).should include(@activity)
        end
      end

      describe "receiver home" do
        it "should include activity" do
          @activity.receiver.wall(:home).should include(@activity)
        end
      end

      describe "alien home" do
        it "should not include activity" do
          Factory(:user).wall(:home).should_not include(@activity)
        end
      end

      describe "sender profile" do
        context "for sender" do
          it "should include activity" do
            @activity.sender.wall(:profile, :for => @activity.sender).should include(@activity)
          end
        end

        context "for receiver" do
          it "should include activity" do
            @activity.sender.wall(:profile, :for => @activity.receiver).should include(@activity)
          end
        end

        context "for Anonymous" do
          it "should include activity" do
            @activity.sender.wall(:profile, :for => nil).should include(@activity)
          end
        end
      end

      describe "receiver profile" do
        context "for sender" do
          it "should include activity" do
            @activity.receiver.wall(:profile, :for => @activity.sender).should include(@activity)
          end
        end

        context "for receiver" do
          it "should include activity" do
            @activity.receiver.wall(:profile, :for => @activity.receiver).should include(@activity)
          end
        end

        context "for Anonymous" do
          it "should include activity" do
            @activity.receiver.wall(:profile, :for => nil).should include(@activity)
          end
        end
      end
    end
  end

  context "user" do
    before(:all) do
      @subject = @user = Factory(:user)
    end

    context "with public activity" do
      before do
        contact = @user.contact_to!(@user)
        create_activity(contact, @user.relation_public)
      end

      describe "sender home" do
        it "should include activity" do
          @activity.sender.wall(:home).should include(@activity)
        end
      end

      describe "sender profile" do
        context "accessed by alien" do
          it "should include activity" do
            @activity.sender.wall(:profile,
                                  :for => Factory(:user)).should include(@activity)
          end
        end

        context "accessed by anonymous" do
          it "should include activity" do
            @activity.sender.wall(:profile,
                                  :for => nil).should include(@activity)
          end
        end
      end
    end

    describe "belonging to friend" do
      before do
        @tie = create_related_tie(:friend)
        create_activity(@tie.contact.inverse!, @tie.relation)
      end

      describe "accessed by sender" do
        before do
          create_ability_accessed_by(@tie.receiver_subject)
        end

        it_should_behave_like "Allows Creating"
        it_should_behave_like "Allows Reading"
        it_should_behave_like "Allows Updating"
        it_should_behave_like "Allows Destroying"
      end
      
      describe "accessed by different friend" do
        before do
          create_ability_accessed_by_related :friend
        end

       it_should_behave_like "Denies Creating"
        it_should_behave_like "Allows Reading"
        it_should_behave_like "Denies Updating"
        it_should_behave_like "Denies Destroying"
      end

      describe "accessed by acquaintance" do
        before do
          create_ability_accessed_by_related :acquaintance
        end


        it_should_behave_like "Denies Creating"
        it_should_behave_like "Denies Reading"
        it_should_behave_like "Denies Updating"
        it_should_behave_like "Denies Destroying"
      end

      describe "accessed publicly" do
        before do
          create_ability_accessed_publicly
        end

        it_should_behave_like "Denies Creating"
        it_should_behave_like "Denies Reading"
        it_should_behave_like "Denies Updating"
        it_should_behave_like "Denies Destroying"
      end
    end
    
    describe "belonging to user's friend relation" do
      before do
        create_activity(@user.contact_to!(@user), @user.relation_custom('friend'))
      end

      describe "accessed by the sender" do
        before do
          create_ability_accessed_by(@user)
        end

        it_should_behave_like "Allows Creating"
        it_should_behave_like "Allows Reading"
        it_should_behave_like "Allows Updating"
        it_should_behave_like "Allows Destroying"
      end
      
      describe "accessed by a friend" do
        before do
          create_ability_accessed_by_related :friend
        end

        it_should_behave_like "Denies Creating"
        it_should_behave_like "Allows Reading"
        it_should_behave_like "Denies Updating"
        it_should_behave_like "Denies Destroying"
      end

      describe "accessed by acquaintance" do
        before do
          create_ability_accessed_by_related :acquaintance
        end

        it_should_behave_like "Denies Creating"
        it_should_behave_like "Denies Reading"
        it_should_behave_like "Denies Updating"
        it_should_behave_like "Denies Destroying"
      end

      describe "accessed publicly" do
        before do
          create_ability_accessed_publicly
        end

        it_should_behave_like "Denies Creating"
        it_should_behave_like "Denies Reading"
        it_should_behave_like "Denies Updating"
        it_should_behave_like "Denies Destroying"
      end
    end

    describe "belonging to user's public relation" do

      before do
        create_activity(@user.contact_to!(@user), @user.relation_public)
      end

      describe "accessed by the sender" do
        before do
          create_ability_accessed_by(@user)
        end

        it_should_behave_like "Allows Creating"
        it_should_behave_like "Allows Reading"
        it_should_behave_like "Allows Updating"
        it_should_behave_like "Allows Destroying"
      end
      
      describe "accessed by a friend" do
        before do
          create_ability_accessed_by_related :friend
        end

        it_should_behave_like "Denies Creating"
        it_should_behave_like "Allows Reading"
        it_should_behave_like "Denies Updating"
        it_should_behave_like "Denies Destroying"
      end

      describe "accessed by acquaintance" do
        before do
          create_ability_accessed_by_related :acquaintance
        end

        it_should_behave_like "Denies Creating"
        it_should_behave_like "Allows Reading"
        it_should_behave_like "Denies Updating"
        it_should_behave_like "Denies Destroying"
      end

      describe "accessed publicly" do
        before do
          create_ability_accessed_publicly
        end

        it_should_behave_like "Denies Creating"
        it_should_behave_like "Allows Reading"
        it_should_behave_like "Denies Updating"
        it_should_behave_like "Denies Destroying"
      end
    end

    describe "belonging to other user's public relation" do

      before do
        @tie = Factory(:public)
        create_activity @tie.contact, @tie.sender.relation_public
        create_ability_accessed_by @tie.receiver_subject
      end
      
      it_should_behave_like "Denies Creating"
    end
  end

  context "group" do
    before(:all) do
      @subject = @group = Factory(:group)
    end

    describe "belonging to member tie" do
      before do
        @tie = create_related_tie(:member)
        create_activity @tie.contact.inverse!, @tie.relation
      end

      describe "accessed by same member" do
        before do
          create_ability_accessed_by @tie.receiver_subject
        end

        it_should_behave_like "Allows Creating"
        it_should_behave_like "Allows Reading"
        it_should_behave_like "Allows Updating"
        it_should_behave_like "Allows Destroying"
      end
      
      describe "accessed by different member" do
        before do
          create_ability_accessed_by_related :member
        end

        it_should_behave_like "Denies Creating"
        it_should_behave_like "Allows Reading"
        it_should_behave_like "Denies Updating"
        it_should_behave_like "Denies Destroying"
      end

      describe "accessed by partner" do
        before do
          create_ability_accessed_by_related :partner
        end

        it_should_behave_like "Denies Creating"
        it_should_behave_like "Denies Reading"
        it_should_behave_like "Denies Updating"
        it_should_behave_like "Denies Destroying"
      end

      describe "accessed publicly" do
        before do
          create_ability_accessed_publicly
        end

        it_should_behave_like "Denies Creating"
        it_should_behave_like "Denies Reading"
        it_should_behave_like "Denies Updating"
        it_should_behave_like "Denies Destroying"
      end
    end
  end
end
