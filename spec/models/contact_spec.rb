require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Contact do
  context "inverse" do
    before do
      @sent = Factory(:contact)
      @received = @sent.inverse!
    end

    it "should be set" do
      @sent.reload.inverse.should eq(@received)
    end
  end

  context "with message" do
    before do
      @sent = Factory(:contact, :message => 'Hello')
      @received = @sent.inverse!
    end

    it "should send to the receiver" do
      @sent.message.should == 'Hello'
      @sent.sender_subject.should eq(@received.receiver_subject)
    end
  end

end
