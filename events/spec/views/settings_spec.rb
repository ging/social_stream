require 'spec_helper'

describe 'settings/_index' do
  let(:user) { stub_model(User, { name: "Test User",
                                  email: "test-user@test.com",
                                  language: 'en' } ) }

  let(:group) { stub_model(Group, { name: "Test Group",
                                    to_param: "test-group" } ) }

  before do
    view.stub(:current_user).and_return(user)
  end

  describe "with user" do
    before do
      view.stub(:current_subject).and_return(user)
    end

    it "does not include room settings" do
      render

      rendered.should_not =~ /room_settings/
    end
  end

  describe "with group" do
    before do
      view.stub(:current_subject).and_return(group)
    end

    it "includes room settings" do
      render

      rendered.should =~ /room_settings/
    end
  end

end
