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

  context "a pair" do
    before do
      @friend = Factory(:friend)
      @sender = @friend.sender
      @acquaintance = Factory(:acquaintance,
                              :contact => Factory(:contact,
                                                  :sender => @sender))
    end

    it "should scope friend" do
      Contact.sent_by(@sender).count.should eq(2)
      Contact.sent_by(@sender).related_by_param(nil).count.should eq(2)
      Contact.sent_by(@sender).related_by_param(@friend.relation_id).count.should eq(1)
    end
  end
end
