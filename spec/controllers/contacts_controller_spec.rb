require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContactsController do

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

end
