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
    it "should allow create to friend" do
      tie = Factory(:friend)

      post = Post.new :text => "testing",
                      :_contact_id => tie.contact.inverse!.id

      assert post.build_post_activity.allow? tie.receiver_subject, 'create'

      ability = Ability.new(tie.receiver_subject)

      ability.should be_able_to(:create, post)
    end

    it "should fill relation" do
      tie = Factory(:friend)

      post = Post.new :text => "testing",
                      :_contact_id => tie.contact.inverse!.id

      post.save!

      post.post_activity.relations.should include(tie.relation)
    end
  end
end
