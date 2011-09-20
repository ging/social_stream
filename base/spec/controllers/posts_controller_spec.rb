require 'spec_helper'


describe PostsController do
  include SocialStream::TestHelpers
  include SocialStream::TestHelpers::Controllers

  render_views

  describe "authorizing" do
    before do
      @user = Factory(:user)
      sign_in @user
    end

    describe "posts to user" do
      describe "with first relation" do
        before do
          contact = @user.contact_to!(@user)
          relation = @user.relation_customs.sort.first
          model_assigned_to @user.contact_to!(@user), relation
          @current_model = Factory(:post, :_contact_id => contact.id, :_relation_ids => Array(relation.id))
        end

        it_should_behave_like "Allow Creating"
        it_should_behave_like "Allow Destroying"
      end

      describe "with last relation" do
        before do
          contact = @user.contact_to!(@user)
          relation = @user.relation_customs.sort.last
          model_assigned_to @user.contact_to!(@user), relation
          @current_model = Factory(:post, :_contact_id => contact.id, :_relation_ids => Array(relation.id))
        end

        it_should_behave_like "Allow Creating"
        it_should_behave_like "Allow Destroying"
      end

      describe "with public relation" do
        before do
          contact = @user.contact_to!(@user)
          relation = @user.relation_public
          model_assigned_to @user.contact_to!(@user), relation
          @current_model = Factory(:post, :_contact_id => contact.id)
        end

        it_should_behave_like "Allow Creating"
        it_should_behave_like "Allow Destroying"
      end
    end

    describe "post to friend" do
      before do
        friend = Factory(:friend, :contact => Factory(:contact, :receiver => @user.actor)).sender

        model_assigned_to @user.contact_to!(friend), friend.relation_custom('friend')
      end

      it_should_behave_like "Allow Creating"
    end

    describe "post to acquaintance" do
      before do
        ac = Factory(:acquaintance, :contact => Factory(:contact, :receiver => @user.actor)).sender

        model_assigned_to @user.contact_to!(ac), ac.relation_custom('acquaintance')
      end

      it_should_behave_like "Deny Creating"
    end

    describe "posts represented group" do
      before do
        @group = Factory(:member, :contact => Factory(:group_contact, :receiver => @user.actor)).sender_subject
      end

      describe "with member relation" do
        before do
          contact = @user.contact_to!(@group)
          relation = @group.relation_custom('member')

          model_assigned_to contact, relation
          @current_model = Factory(:post, :_contact_id => contact.id, :_relation_ids => Array(relation.id))
        end

        it_should_behave_like "Allow Creating"
        it_should_behave_like "Allow Destroying"
      end

      context "representing the group" do
        before do
          represent(@group)
        end

        describe "with first relation" do
          before do
            contact = @group.contact_to!(@group)
            relation = @group.relation_customs.sort.first
            model_assigned_to contact, relation
            @current_model = Factory(:post, :_contact_id => contact.id, :_relation_ids => Array(relation.id))
          end

          it_should_behave_like "Allow Creating"
          it_should_behave_like "Allow Destroying"
        end

        describe "with last relation" do
          before do
            contact = @group.contact_to!(@group)
            relation = @group.relation_customs.sort.last
            model_assigned_to contact, relation
            @current_model = Factory(:post, :_contact_id => contact.id, :_relation_ids => Array(relation.id))
          end

          it_should_behave_like "Allow Creating"
          it_should_behave_like "Allow Destroying"
        end

        describe "with public relation" do
          before do
            contact = @group.contact_to!(@group)
            relation = @group.relation_public
            model_assigned_to contact, relation
            @current_model = Factory(:post, :_contact_id => contact.id, :_relation_ids => Array(relation.id))
          end

          it_should_behave_like "Allow Creating"
          it_should_behave_like "Allow Destroying"
        end
      end
    end
  end

  context "creating post in group's wall" do
    before do
      @tie = Factory(:member)
    end

    it "should assign activity to member" do
      sign_in @tie.receiver_subject

      post :create, :post => { :text => "Test",
                               :_contact_id => @tie.contact.inverse!.id,
                             }

      post = assigns(:post)

      post.should be_valid
      post.post_activity.relations.should include(@tie.relation)
    end
  end

  context "creating public post" do
    before do
      @post = Factory(:public_post)
    end

    it "should render" do
      get :show, :id => @post.to_param

      response.should be_success
    end
  end
end

