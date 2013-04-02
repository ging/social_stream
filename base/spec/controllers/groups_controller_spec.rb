require 'spec_helper'

describe GroupsController do
  include SocialStream::TestHelpers
  include SocialStream::TestHelpers::Controllers

  render_views

  describe "when Anonymous" do
    it "should render index" do
      get :index

      assert_response :success
    end

    it "should render index with most followed" do
      get :index, :most => 'followed'

      response.should be_success
    end

    it "should render show" do
      get :show, :id => Factory(:group).to_param

      assert_response :success
    end

    it "should not render new" do
      get :new

      response.should redirect_to(new_user_session_path)
    end

    context "faking a new group" do
      it "should deny creating" do
        post :create, :group => { :name => "Test" }

        response.should redirect_to(new_user_session_path)
      end
    end

    context "an existing group" do
      before do
        @current_model = Factory(:group)
      end

      it_should_behave_like "Deny Updating"
      it_should_behave_like "Deny Destroying"
    end
  end

  describe "when authenticated" do
    before do
      @user = Factory(:user)

      sign_in @user
    end

    it "should render index" do
      get :index

      assert_response :success
    end

    it "should render contact group" do
      @group = Factory(:member, :contact => Factory(:group_contact, :receiver => @user.actor)).sender_subject
      get :show, :id => @group.to_param

      response.should be_success
      response.body.should =~ /new_post/
    end

    it "should render other group" do
      get :show, :id => Factory(:group).to_param

      assert_response :success
    end

    it "should render new" do
      get :new

      assert_response :success
    end

    context "a new own group" do
      it "should allow creating" do
        count = Group.count
        post :create, :group => { :name => "Test" }

        group = assigns(:group)

        group.should be_valid
        Group.count.should eq(count + 1)
        assigns(:current_subject).should eq(group)
        response.should redirect_to(:home)
        @user.senders.should include(group.actor)
      end

      context "with participants" do
        before do
          @user_participant = Factory(:user)
          @group_participant = Factory(:group)
        end

        it "should allow creating" do
          count = Group.count
          post :create,
               :group => { :name => "Test group",
                           :_participants => [ @user_participant.actor_id, @group_participant.actor_id ].join(',') }

          group = assigns(:group)

          group.should be_valid
          Group.count.should eq(count + 1)
          assigns(:current_subject).should eq(group)

          participants = group.contact_subjects(:direction => :sent)

          participants.should include(@user_participant)
          participants.should include(@group_participant)

          group.contact_subjects(:direction => :received)
          response.should redirect_to(:home)
        end
      end
    end

    context "a new fake group" do
      before do
        user = Factory(:user)

        model_attributes[:author_id] = user.actor_id
        model_attributes[:user_author_id] = user.actor_id
      end

      it_should_behave_like "Deny Creating"
    end

    context "a external group" do
      before do
        @current_model = Factory(:group)
      end

      it_should_behave_like "Deny Updating"
      it_should_behave_like "Deny Destroying"
    end


    context "a existing own group" do
      before do
        @current_model = Factory(:member, :contact => Factory(:group_contact, :receiver => @user.actor)).sender_subject
      end

      it "should update contact group" do
        put :update, :id => @current_model.to_param,
                     "group" => { "profile_attributes" => { "organization" => "Social Stream" } }

        response.should redirect_to(@current_model)
      end

      # it_should_behave_like "Allow Updating"
      it_should_behave_like "Allow Destroying"
    end

    context "representing a group" do
      before do
        @group = Factory(:member, :contact => Factory(:group_contact, :receiver => @user.actor)).sender_subject
        represent(@group)
      end

      it "should allow creating" do
        count = Group.count
        post :create, :group => { :name => "Test new group" }

        new_group = assigns(:group)

        new_group.should be_valid
        Group.count.should eq(count + 1)
        assigns(:current_subject).should eq(new_group)
        response.should redirect_to(:home)
        @user.senders.should include(new_group.actor)
        @group.senders.should include(new_group.actor)
      end
    end
  end
end

