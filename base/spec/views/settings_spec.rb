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

    it "includes user name" do
      render

      rendered.should =~ /Test User/
    end
  end

  describe "with group" do
    before do
      view.stub(:current_subject).and_return(group)
    end

    it "includes group name" do
      render

      rendered.should =~ /Test Group/
    end
  end

end
