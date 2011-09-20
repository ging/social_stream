require 'spec_helper'

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

  context "spurious" do
    before do
      @contact = Factory(:contact)
      @contact.inverse!
    end

    it "should not appear as pending" do
      @contact.sender.pending_contacts.should_not include(@contact)
    end
  end
end
