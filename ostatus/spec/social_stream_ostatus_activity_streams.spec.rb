require 'spec_helper'

describe SocialStream::Ostatus::ActivityStreams do
  before do
    @entry = double("Proudhon::Entry")

    @remote_subject = double("RemoteSubject")

    Proudhon::Atom.should_receive(:parse) { [ @entry ] }
  end

  describe "with post note" do
    before do
      @entry.should_receive(:verb) { :post }
      @entry.should_receive(:objtype) { :note }

      @post = double "post"

      @post.should_receive :post_activity

      Post.should_receive(:from_entry!).with(@entry) { @post }
    end

    it "should call stubs" do
      SocialStream::ActivityStreams.from_pshb_callback "test"
    end
  end
end

