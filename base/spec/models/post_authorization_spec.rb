require 'spec_helper'

module PostAuthorizationTestHelper
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
      @ability.should be_able_to(:create, @post)
    end
  end

  shared_examples_for "Allows Reading" do
    it "should allow read" do
      @ability.should be_able_to(:read, @post)
    end
  end

  shared_examples_for "Allows Updating" do
    it "should allow update" do
      @ability.should be_able_to(:update, @post)
    end
  end

  shared_examples_for "Allows Destroying" do
    it "should allow destroy" do
      @ability.should be_able_to(:destroy, @post)
    end
  end

  shared_examples_for "Denies Creating" do
    it "should deny create" do
      @ability.should_not be_able_to(:create, @post)
    end
  end

  shared_examples_for "Denies Reading" do
    it "should deny read" do
      @ability.should_not be_able_to(:read, @post)
    end
  end

  shared_examples_for "Denies Updating" do
    it "should deny update" do
      @ability.should_not be_able_to(:update, @post)
    end
  end

  shared_examples_for "Denies Destroying" do
    it "should deny destroy" do
      @ability.should_not be_able_to(:destroy, @post)
    end
  end
end

describe Post do
  include PostAuthorizationTestHelper

  before :all do
    @subject = @user = Factory(:user)
  end

  context "with friend tie" do
    before :all do
      @tie = create_related_tie(:friend)
    end

    describe "posting for all contacts" do
      before :all do
        @post = Factory(:post,
                        :author => @tie.receiver,
                        :owner  => @tie.sender)
      end

      describe "accesed by author" do
        before do
          create_ability_accessed_by(@post.author_subject)
        end

        it_should_behave_like "Allows Creating"
        it_should_behave_like "Allows Reading"
        it_should_behave_like "Allows Updating"
        it_should_behave_like "Allows Destroying"
      end

      describe "accesed by owner" do
        before do
          create_ability_accessed_by(@post.owner_subject)
        end

        it_should_behave_like "Denies Creating"
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
        it_should_behave_like "Allows Reading"
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

    describe "posting only to friends" do
      before :all do
        @post = Factory(:post,
                        :author => @tie.receiver,
                        :owner  => @tie.sender,
                        :relation_ids => [@tie.relation_id])

      end

      describe "accessed by author" do
        before do
          create_ability_accessed_by(@post.author_subject)
        end

        it_should_behave_like "Allows Creating"
        it_should_behave_like "Allows Reading"
        it_should_behave_like "Allows Updating"
        it_should_behave_like "Allows Destroying"
      end

      describe "accesed by owner" do
        before do
          create_ability_accessed_by(@post.owner_subject)
        end

        it_should_behave_like "Denies Creating"
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

    describe "posting to public relation" do

      before do
        @post = Factory(:post,
                        :author => @tie.receiver,
                        :owner  => @tie.sender,
                        :relation_ids => [Relation::Public.instance.id])
      end

      describe "accessed by author" do
        before do
          create_ability_accessed_by(@post.author_subject)
        end

        it_should_behave_like "Allows Creating"
        it_should_behave_like "Allows Reading"
        it_should_behave_like "Allows Updating"
        it_should_behave_like "Allows Destroying"
      end

      describe "accessed by owner" do
        before do
          create_ability_accessed_by(@post.owner_subject)
        end

        it_should_behave_like "Denies Creating"
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

    describe "posting by not replied" do
      before :all do
        @post = Factory(:post,
                        :author => @tie.sender,
                        :owner  => @tie.receiver)
      end

      describe "accessed by author" do
        before do
          create_ability_accessed_by(@post.author_subject)
        end

        it_should_behave_like "Denies Creating"
      end
    end
  end

  context "group" do
    before(:all) do
      @subject = @group = Factory(:group)
    end

    describe "with member tie" do
      before :all do
        @tie = create_related_tie(:member)
      end

      describe "posting from member all contacts" do
        before :all do
          @post = Factory(:post,
                          :author => @tie.receiver,
                          :owner  => @tie.sender)
        end

        describe "accessed by author" do
          before do
            create_ability_accessed_by @post.author_subject
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
          it_should_behave_like "Allows Reading"
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
end
