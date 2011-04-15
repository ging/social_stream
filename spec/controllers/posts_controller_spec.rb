require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


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
          tie = @user.sent_ties.received_by(@user).related_by(@user.relations.sort.first).first
          model_assigned_to tie
          @current_model = Factory(:post, :_activity_tie_id => tie)
        end

        it_should_behave_like "Allow Creating"
        it_should_behave_like "Allow Destroying"
      end

      describe "with last relation" do
        before do
          tie = @user.sent_ties.received_by(@user).related_by(@user.relations.sort.last).first
          model_assigned_to tie
          @current_model = Factory(:post, :_activity_tie_id => tie)
        end

        it_should_behave_like "Allow Creating"
        it_should_behave_like "Allow Destroying"
      end

      describe "with public relation" do
        before do
          tie = @user.sent_ties.received_by(@user).related_by(@user.relation_public).first
          model_assigned_to tie
          @current_model = Factory(:post, :_activity_tie_id => tie)
        end

        it_should_behave_like "Allow Creating"
        it_should_behave_like "Allow Destroying"
      end

    end

    describe "post to friend" do
      before do
        friend = Factory(:friend, :receiver => @user.actor).sender

        model_assigned_to friend.activity_ties_for(@user).first
      end

      it_should_behave_like "Allow Creating"
    end

    describe "post to acquaintance" do
      before do
        ac = Factory(:acquaintance, :receiver => @user.actor).sender

        model_assigned_to Factory(:friend, :sender => @user.actor, :receiver => ac)
      end

      it_should_behave_like "Deny Creating"
    end

    describe "posts represented group" do
      before do
        @group = Factory(:member, :receiver_id => @user.actor_id).sender_subject
      end

      describe "with public relation" do
        before do
          tie = @group.activity_ties_for(@user).first
          model_assigned_to tie
          @current_model = Factory(:post, :_activity_tie_id => tie)
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
            tie = @group.sent_ties.received_by(@group).related_by(@group.relations.sort.first).first
            model_assigned_to tie
            @current_model = Factory(:post, :_activity_tie_id => tie)
          end

          it_should_behave_like "Allow Creating"
          it_should_behave_like "Allow Destroying"
        end

        describe "with last relation" do
          before do
            tie = @group.sent_ties.received_by(@group).related_by(@group.relations.sort.last).first
            model_assigned_to tie
            @current_model = Factory(:post, :_activity_tie_id => tie)
          end

          it_should_behave_like "Allow Creating"
          it_should_behave_like "Allow Destroying"
        end

        describe "with public relation" do
          before do
            tie = @group.sent_ties.received_by(@group).related_by(@group.relation_public).first
            model_assigned_to tie
            @current_model = Factory(:post, :_activity_tie_id => tie)
          end

          it_should_behave_like "Allow Creating"
          it_should_behave_like "Allow Destroying"
        end
      end
    end
  end
end

