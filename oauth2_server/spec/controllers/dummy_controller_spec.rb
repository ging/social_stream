require 'spec_helper'

describe DummyController do
  DummyController.class_eval do
    before_filter :current_subject
  end

  let(:client) { double :client }
  let(:user)   { double :user }

  let(:token) { stub :token, client: client }
  let(:find) { stub :find, { find_by_token: token } }

  before do
    controller.request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN] = token
  end

  describe "with user token" do
    before do
      token.stub(:user).and_return(user)
    end

    it "should have user as current_subject" do
      get :index

      assigns(:current_subject).should be_present
      assigns(:current_subject).should eq(user)
    end
  end

  describe "with client token" do
    before do
      token.stub(:user).and_return(nil)
    end

    it "should have client as current_subject" do
      get :index

      assigns(:current_subject).should be_present
      assigns(:current_subject).should eq(client)
    end
  end
end
