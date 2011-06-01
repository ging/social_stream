require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Relation::CustomsController do
  include SocialStream::TestHelpers::Controllers

  render_views

  describe "when authenticated" do
    before do
      @user = Factory(:user)

      sign_in @user
    end

    context "with an existing sphere" do
      before do
        @sphere = Factory(:sphere, :actor_id => @user.actor_id)
      end

      it "should render index" do
        get :index, :sphere_id => @sphere.id, :format => "js"

        response.should be_success
      end

      context "a new relation" do
        it "should be created" do
          count = Relation::Custom.count

          post :create, :custom => { :name => "Test create", :sphere_id => @sphere.id }, :format => 'js'

          relation = assigns(:custom)

          Relation::Custom.count.should eq(count + 1)
          relation.should be_valid
          response.should be_success
        end

      end

      context "a existing own relation" do
        before do
          @relation = Factory(:relation_custom, :sphere_id => @sphere.id)
          @relation.reload
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
          pending "Delete relations"

          count = Relation::Custom.count

          delete :destroy, :id => @relation.to_param, :format => :js

          Relation::Custom.count.should eq(count - 1)
        end
      end

    end

    context "with a fake sphere" do
      before do
        @sphere = Factory(:sphere)
      end

      it "should not render index" do
	begin
          get :index, :sphere_id => @sphere.id, :format => "js"

	  # Should not get here
          assert false
        rescue CanCan::AccessDenied
          assigns(:customs).should be_blank
        end
      end

      context "a new relation" do
        it "should belong to user" do
          count = Relation::Custom.count

          begin
            post :create, :relation_custom => { :name => "Test create", :sphere_id => @sphere.id }, :format => 'js'

            assert false
          rescue CanCan::AccessDenied

            Relation::Custom.count.should eq(count)
          end
        end
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

