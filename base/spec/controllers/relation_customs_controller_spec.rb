require 'spec_helper'

describe Relation::CustomsController do
  render_views

  describe "when Anonymous" do
    context "faking a new relation" do
      it "should not create" do
        post :create, :custom => Factory.attributes_for(:relation_custom)

        response.should redirect_to(:new_user_session)
      end
    end

    context "an existing relation" do
      before do
        @relation = Factory(:relation_custom)
      end

      it "should not update" do
        put :update, :id => @relation.to_param, :custom => { :name => 'Testing' }

        assigns(:custom).should be_blank
        response.should redirect_to(:new_user_session)
      end

      it "should not destroy" do
        count = Relation.count
        begin
          delete :destroy, :id => @relation.to_param
        rescue CanCan::AccessDenied
        end

        relation = assigns(:custom)

        Relation.count.should eq(count)
      end

    end
  end


  describe "when authenticated" do
    before do
      @user = Factory(:user)

      sign_in @user
    end

    it "should render index" do
      get :index

      response.should be_success
    end

    context "a new own relation" do
      it "should be created" do
        count = Relation::Custom.count

        post :create, :custom => { :name => "Test create", :actor_id => @user.actor_id }, :format => 'js'

        relation = assigns(:custom)

        Relation::Custom.count.should eq(count + 1)
        relation.should be_valid
        response.should be_success
      end
    end

    context "a new fake relation" do
      it "should not be created" do
        actor = Factory(:user).actor
        count = Relation.count
	begin
          post :create, :custom => { :name => 'Test', :actor_id => actor.id }

          assert false
        rescue CanCan::AccessDenied
          assigns(:custom).should be_new_record

          Relation.count.should eq(count)
        end
      end
    end

    context "a existing own relation" do
      before do
        @relation = Factory(:relation_custom, :actor => @user.actor)
      end

      it "should allow updating" do
        attrs = { :name => "Updating own" }

        put :update, :id => @relation.to_param, :relation_custom => attrs, :format => 'js'

        relation = assigns(:custom)

#          relation.should_receive(:update_attributes).with(attrs)
        relation.should be_valid
        response.should be_success
      end

      it "should allow destroying" do
        count = Relation::Custom.count

        delete :destroy, :id => @relation.to_param

        Relation::Custom.count.should eq(count - 1)
      end
    end

    context "a external relation" do
      before do
        @relation = Factory(:relation_custom)
      end

      it "should not allow updating" do
        begin
          put :update, :id => @relation.to_param, :relation_custom => { :name => "Updating external" }, :format => 'js'

          assert false
        rescue CanCan::AccessDenied
          assigns(:relation).should be_nil
        end
      end

      it "should not allow destroying" do
        begin
          delete :destroy, :id => @relation.to_param

          assert false
        rescue CanCan::AccessDenied
          assigns(:relation).should be_nil
        end
      end
    end
  end
end

