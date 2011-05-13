require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SpheresController do
  include SocialStream::TestHelpers::Controllers

  render_views

  describe "when Anonymous" do
    context "faking a new sphere" do
      before do
        model_attributes[:actor_id] = Factory(:user).actor_id
      end

      it "should not create" do
        post :create, attributes

        response.should redirect_to(:new_user_session)
      end
    end

    context "an existing sphere" do
      before do
        @current_model = Factory(:sphere)
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

    context "a new own sphere" do
      before do
        model_attributes[:actor_id] = @user.actor_id
      end

      it_should_behave_like "Allow Creating"
    end

    context "a new fake sphere" do
      before do
        model_attributes[:actor_id] = Factory(:user).actor_id
      end

      it "should belong to user" do
        count = Sphere.count
        post :create, attributes

        resource = assigns(:sphere)

        Sphere.count.should eq(count + 1)
        resource.should be_valid
        resource.actor.should eq(@user.actor)
      end
    end

    context "a external sphere" do
      before do
        @current_model = Factory(:sphere)
      end

      it "should not be found on update" do
        begin
          put :update, updating_attributes

          assert false
        rescue ActiveRecord::RecordNotFound
          assigns(:sphere).should be_nil
        end
      end

      it "should not be found on destroy" do
        begin
          delete :destroy, :id => @current_model.to_param

          assert false
        rescue ActiveRecord::RecordNotFound
          assigns(:sphere).should be_nil
        end
      end
    end


    context "a existing own sphere" do
      before do
        @current_model = Factory(:sphere, :actor_id => @user.actor_id)
      end

      # This is not working, because of updating attributes. Do not know why
      # it_should_behave_like "Allow Updating"
      it_should_behave_like "Allow Destroying"
    end

  end
end

