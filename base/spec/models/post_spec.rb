require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
end
