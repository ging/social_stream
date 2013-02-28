require 'spec_helper'

describe 'settings/_index' do
  let(:user) { stub_model(User, { name: "Test User",
                                  email: "test-user@test.com",
                                  language: 'en' } ) }

  let(:group) { stub_model(Group, { name: "Test Group",
                                    to_param: "test-group" } ) }

  before do
    SocialStream::Presence.stub(:enable) { true }

    view.stub(:current_user).and_return(user)
  end

  describe "with user" do
    before do
      view.stub(:current_subject).and_return(user)
    end

    it "includes chat settings" do
      render

      rendered.should =~ /chat_settings/
    end
  end

  describe "with group" do
    before do
      view.stub(:current_subject).and_return(group)
    end

    it "does not include chat settings" do
      render

      rendered.should_not =~ /chat_settings/
    end
  end

end
