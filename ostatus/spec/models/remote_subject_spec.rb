require 'spec_helper'

describe RemoteSubject do
  describe "find_or_create_by_webfinger_id" do
    before do
      @remote_subject = Factory(:remote_subject)
    end

    it "should call without acct:" do
      RemoteSubject.find_or_create_by_webfinger_uri("acct:#{ @remote_subject.webfinger_id}").should == @remote_subject
    end
    
    it "should call without acct:" do
      RemoteSubject.find_or_create_by_webfinger_uri!("acct:#{ @remote_subject.webfinger_id}").should == @remote_subject
    end
  end
end
