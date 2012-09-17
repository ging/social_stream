require 'spec_helper'

describe Post do
  describe "from_entry!" do
    before do
      @remote_subject = Factory(:remote_subject)
      @entry = double("Proudhon::Entry")

      SocialStream::ActivityStreams.should_receive(:actor_from_entry!) { @remote_subject }

      @entry.should_receive(:title) { "testing" } 
      @entry.should_receive(:content) { "testing" }

    end
    it "should create post" do
      post_count = Post.count

      post = Post.from_entry! @entry

      post.author.should == @remote_subject.actor

      Post.count.should == post_count + 1
    end
  end
end
