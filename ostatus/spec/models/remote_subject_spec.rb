require 'spec_helper'

describe RemoteSubject do
  describe "find_or_create_by_webfinger_uri" do
    before do
      @remote_subject = Factory(:remote_subject)
    end

    it "should find without acct:" do
      RemoteSubject.find_or_create_by_webfinger_uri!(@remote_subject.webfinger_id).should == @remote_subject
    end

    it "should find with acct:" do
      RemoteSubject.find_or_create_by_webfinger_uri!("acct:#{ @remote_subject.webfinger_id}").should == @remote_subject
    end

    it "should find with alias" do
      splt = @remote_subject.webfinger_id.split('@')
      uri = "http://#{ splt.last }/#{ splt.first }"

      RemoteSubject.find_or_create_by_webfinger_uri!(uri)
    end
  end
end
