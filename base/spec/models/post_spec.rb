require 'spec_helper'

describe Post do
  before do
    @post = Factory(:post)
    @post_activity_object = @post.activity_object
    @post_activity = @post.post_activity
  end 

  describe "with like activity" do
    before do
      @like_activity = Factory(:like_activity, :parent => @post_activity)
    end

    describe "when destroying" do
      before do
        @post.try(:destroy)
      end

      it "should also destroy its activity_object" do
        assert_nil ActivityObject.find_by_id(@post_activity_object.id)
      end

      it "should also destroy its post_activity" do
        assert_nil Activity.find_by_id(@post_activity.id)
      end

      it "should also destroy its children like activity" do
        assert_nil Activity.find_by_id(@like_activity.id)
      end
    end
  end

  context "without relations" do
    before :all do
      @ss_relation_model = SocialStream.relation_model
    end

    after :all do
      SocialStream.relation_model = @ss_relation_model
    end

    context "in follow relation model" do
      before do
        SocialStream.relation_model = :follow
      end

      it "should allow create to follower" do
        tie = Factory(:follow)

        post = Post.new :text => "testing",
                        :author_id => tie.receiver.id,
                        :owner_id => tie.sender.id,
                        :user_author_id => tie.receiver.id

        ability = Ability.new(tie.receiver_subject)

        ability.should be_able_to(:create, post)
      end

      it "should fill relation" do
        tie = Factory(:follow)

        post = Post.new :text => "testing",
          :author_id => tie.receiver.id,
          :owner_id => tie.sender.id,
          :user_author_id => tie.receiver.id

        post.save!

        post.post_activity.relations.should include(Relation::Public.instance)
      end

    end

    context "in custom relation model" do
      before do
        SocialStream.relation_model = :custom
      end

      it "should allow create to friend" do
        tie = Factory(:friend)

        post = Post.new :text => "testing",
          :author_id => tie.receiver.id,
          :owner_id => tie.sender.id,
          :user_author_id => tie.receiver.id

        ability = Ability.new(tie.receiver_subject)

        ability.should be_able_to(:create, post)
      end

      it "should fill relation" do
        tie = Factory(:friend)

        post = Post.new :text => "testing",
          :author_id => tie.receiver.id,
          :owner_id => tie.sender.id,
          :user_author_id => tie.receiver.id

        post.save!

        post.post_activity.relations.should include(tie.relation)
      end
    end

    describe "a new post" do
      before do
        @user = Factory(:user)
        @post = Post.create!(:text => "test",
                             :author_id => @user.actor_id)
      end

      it "should be shared with user relations" do
        @post.relation_ids.sort.should eq(@user.relation_ids.sort)
      end
    end
  end

  describe "authored_by" do
    it "should work" do
      post = Factory(:post)

      Post.authored_by(post.author).should include(post)
    end
  end


end
