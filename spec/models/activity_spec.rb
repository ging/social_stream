require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module ActivityTestHelper
  def create_activity_assigned_to(t)
    @tie = t
    @activity = Factory(:activity, :tie => t)
  end

  def create_ability_accessed_by(tie_type)
    t = Factory(tie_type, :receiver => @tie.receiver)
    u = t.sender.subject
    @ability = Ability.new(u)
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

  describe "belonging to friend tie" do
    before do
      create_activity_assigned_to(Factory(:friend_tie))
    end

    describe "accessed by same friend" do
      before do
        u = @tie.sender.subject
        @ability = Ability.new(u)
      end

      it_should_behave_like "Allows Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end
    
    describe "accessed by different friend" do
      before do
        create_ability_accessed_by :friend_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed by friend of friend" do
      before do
        create_ability_accessed_by :fof_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Denies Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed publicly" do
      before do
        create_ability_accessed_by :public_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Denies Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end
  end
  
  describe "belonging to fof tie from a friend" do
    before do
      create_activity_assigned_to(Factory(:friend_tie).related('friend_of_friend'))
    end
    
    describe "accessed by a friend" do
      before do
        create_ability_accessed_by :friend_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed by same friend" do
      before do
        u = @tie.sender.subject
        @ability = Ability.new(u)
      end

      it_should_behave_like "Allows Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end
    
    describe "accessed by different friend of friend" do
      before do
        create_ability_accessed_by :fof_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed publicly" do
      before do
        create_ability_accessed_by :public_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Denies Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end
  end

  describe "belonging to fof tie from a friend of friend" do
    before do
      create_activity_assigned_to(Factory(:fof_tie))
      u = @tie.sender.subject
      @ability = Ability.new(u)
    end
    
    it_should_behave_like "Denies Creating"
  end

 
  describe "belonging to public tie" do
    before do
      create_activity_assigned_to(Factory(:friend_tie).related('public'))
    end
    
    describe "accessed by a friend" do
      before do
        create_ability_accessed_by :friend_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed by friend of friend" do
      before do
        create_ability_accessed_by :fof_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed by same public sender" do
      before do
        u = @tie.sender.subject
        @ability = Ability.new(u)
      end

      it_should_behave_like "Allows Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end

    describe "accessed by different public" do
      before do
        create_ability_accessed_by :public_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end
  end

  describe "belonging to public tie from a public" do
    before do
      create_activity_assigned_to(Factory(:public_tie))
      u = @tie.sender.subject
      @ability = Ability.new(u)
    end
    
    it_should_behave_like "Denies Creating"
  end

  describe "belonging to admin tie" do
    before do
      create_activity_assigned_to(Factory(:admin_tie))
    end

    describe "accessed by same admin" do
      before do
        u = @tie.sender.subject
        @ability = Ability.new(u)
      end

      it_should_behave_like "Allows Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end
    
    describe "accessed by different admin" do
      before do
        create_ability_accessed_by :admin_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end

    describe "accessed by user" do
      before do
        create_ability_accessed_by :user_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Denies Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed by follower" do
      before do
        create_ability_accessed_by :follower_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Denies Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end
  end
  
  describe "belonging to user tie from an admin" do
    before do
      create_activity_assigned_to(Factory(:admin_tie).related('user'))
    end
    
    describe "accessed by a admin" do
      before do
        create_ability_accessed_by :admin_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end

    describe "accessed by same admin" do
      before do
        u = @tie.sender.subject
        @ability = Ability.new(u)
      end

      it_should_behave_like "Allows Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end
    
    describe "accessed by different user" do
      before do
        create_ability_accessed_by :user_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end

    describe "accessed by follower" do
      before do
        create_ability_accessed_by :follower_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Denies Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end
  end

  describe "belonging to follower tie" do
    before do
      create_activity_assigned_to(Factory(:user_tie).related('follower'))
    end
    
    describe "accessed by an admin" do
      before do
        create_ability_accessed_by :admin_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end

    describe "accessed by user" do
      before do
        create_ability_accessed_by :user_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end

    describe "accessed by same sender" do
      before do
        u = @tie.sender.subject
        @ability = Ability.new(u)
      end

      it_should_behave_like "Allows Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end

    describe "accessed by different follower" do
      before do
        create_ability_accessed_by :follower_tie
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end
  end

  describe "belonging to follower tie from a follower" do
    before do
      create_activity_assigned_to(Factory(:follower_tie))
      u = @tie.sender.subject
      @ability = Ability.new(u)
    end
    
    it_should_behave_like "Denies Creating"
  end

end
