require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module ActivityTestHelper
  def create_activity_assigned_to(tie)
    @tie = tie
    @activity = Factory(:activity, :tie => tie)
  end

  def create_ability_accessed_by(tie_type)
    t = Factory(tie_type, :receiver => @tie.receiver)
    u = t.sender_subject
    @ability = Ability.new(u)
  end

  def create_ability_accessed_by_sender
    u = @tie.sender_subject
    @ability = Ability.new(u)
  end

  def create_ability_accessed_publicly
    @ability = Ability.new(Factory(:user))
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

  describe "with like subactivity" do
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

  describe "belonging to friend" do
    before do
      create_activity_assigned_to(Factory(:friend))
    end

    describe "accessed by sender" do
      before do
        create_ability_accessed_by_sender
      end

      it_should_behave_like "Allows Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end
    
    describe "accessed by different friend" do
      before do
        create_ability_accessed_by :friend
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed by friend request" do
      before do
        create_ability_accessed_by :friend_request
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
  
  describe "belonging to friend reflexive tie" do
    before do
      tie = Factory(:user).ties.where(:relation_id => Relation.mode('User', 'User').find_by_name('friend')).first
      create_activity_assigned_to(tie)
    end

    describe "accessed by the sender" do
      before do
        create_ability_accessed_by_sender
      end

      it_should_behave_like "Allows Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end
    
    describe "accessed by a friend" do
      before do
        create_ability_accessed_by :friend
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed by friend request" do
      before do
        create_ability_accessed_by :friend_request
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

  describe "belonging to public tie" do

    before do
      tie = Factory(:user).ties.where(:relation_id => Relation.mode('User', 'User').find_by_name('public')).first
      create_activity_assigned_to(tie)
    end

    describe "accessed by the sender" do
      before do
        create_ability_accessed_by_sender
      end

      it_should_behave_like "Allows Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end
    
    describe "accessed by a friend" do
      before do
        create_ability_accessed_by :friend
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed by friend request" do
      before do
        create_ability_accessed_by :friend_request
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

  describe "belonging to public tie from a public" do

    before do
      create_activity_assigned_to(Factory(:public))
      create_ability_accessed_by_sender
    end
    
    it_should_behave_like "Denies Creating"
  end

  describe "belonging to member tie" do
    before do
      create_activity_assigned_to(Factory(:member))
    end

    describe "accessed by same member" do
      before do
        create_ability_accessed_by_sender
      end

      it_should_behave_like "Allows Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end
    
    describe "accessed by different member" do
      before do
        create_ability_accessed_by :member
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end

    describe "accessed by follower" do
      before do
        create_ability_accessed_by :follower
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
  
  describe "belonging to public tie from an admin" do

    before do
      create_activity_assigned_to(Factory(:member).related('public'))
    end

    describe "accessed by sender" do
      before do
        create_ability_accessed_by_sender
      end

      it_should_behave_like "Allows Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end
    
    describe "accessed by other member" do
      before do
        create_ability_accessed_by :member
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end

   
    describe "accessed by follower" do
      before do
        create_ability_accessed_by :follower
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

end
