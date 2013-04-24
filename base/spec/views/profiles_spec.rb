require 'spec_helper'

describe 'profiles/show' do
  let(:user) { stub_model(User, { name: "Test User",
                                  email: "test-user@test.com",
                                  language: 'en',
                                  to_param: "test",
                                  actor: stub_model(Actor),
                                  suggestions: []
                                 })
             }

  let(:other_user) { stub_model(User, { name: "Other User",
                                        email: "other-user@test.com",
                                        language: 'en',
                                        to_param: "other-user",
                                        actor: stub_model(Actor, { contact_to!: stub_model(Contact, { id: 3 })}),
                                        contact_to!: stub_model(Contact, { id: 3 }),
                                        suggestions: []
                                 })
             }


  let(:profile) { stub_model(Profile,
    { subject: user,
      actor: stub_model(Actor)}) }

  let(:group) { stub_model(Group, { name: "Test Group",
                                   to_param: "test-group" } ) }

  before do
    assign :profile, profile
  end

  context "self profile" do
    before do
      view.stub(:current_subject).and_return(user)
      view.stub(:current_user).and_return(user)
      view.stub(:profile_or_current_subject).and_return(user)
      view.stub(:user_signed_in?).and_return(true)
      view.stub(:can?).and_return(true)
      view.stub(:contact_to).and_return("")
    end

    it "should render" do
      render

      rendered.should =~ /#{ user.name }/
      rendered.should =~ /form.*edit_profile/
    end
  end

  context "other profile" do
    before do
      user.stub(:contact_to!, stub_model(Contact, { id: 3 }))
    end

    context "with other user" do
      before do
        view.stub(:current_subject).and_return(other_user)
        view.stub(:current_user).and_return(other_user)
        view.stub(:current_actor).and_return(other_user.actor)
        view.stub(:profile_or_current_subject).and_return(other_user)
        view.stub(:user_signed_in?).and_return(true)
        view.stub(:can?).and_return(false)
      end

      it "should render" do
        render

        rendered.should =~ /#{ user.name }/
        rendered.should_not =~ /form.*edit_profile/
      end
    end

    context "public" do
      before do
        view.stub(:current_subject).and_return(other_user)
        view.stub(:current_user).and_return(other_user)
        view.stub(:current_actor).and_return(other_user.actor)
        view.stub(:profile_or_current_subject).and_return(other_user)
        view.stub(:user_signed_in?).and_return(true)
        view.stub(:can?).and_return(false)
      end

      it "should render" do
        render

        rendered.should =~ /#{ user.name }/
        rendered.should_not =~ /form.*edit_profile/
      end
    end
  end
end
