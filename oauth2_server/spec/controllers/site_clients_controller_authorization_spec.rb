require 'spec_helper'

describe Site::ClientsController do
  include SocialStream::TestHelpers
  include SocialStream::TestHelpers::Controllers

  render_views

  describe "when Anonymous" do
    it "should not render new" do
      get :new

      response.should redirect_to(new_user_session_path)
    end

    context "faking a new client" do
      it "should deny creating" do
        post :create, :client => { :name => "Test" }

        response.should redirect_to(new_user_session_path)
      end
    end

    context "an existing client" do
      before do
        @current_model = Factory(:"site/client")
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

    it "should render client" do
      @client = Factory(:"site/client", author: @user.actor )
      get :show, :id => @client.to_param

      response.should be_success
    end

    it "should render other group" do
      get :show, :id => Factory(:"site/client").to_param

      response.should be_success
    end

    it "should render new" do
      get :new

      response.should be_success
    end

    context "a new own client" do
      it "should allow creating" do
        count = Site::Client.count
        post :create, site_client: { name: "Test",
                                    url: "http://test.com/",
                                    callback_url: "http://test.com/callback"
                                   }

        client = assigns(:client)

        client.should be_valid
        Site::Client.count.should eq(count + 1)
        client.receivers.should include(@user.actor)
      end
    end

    context "a new fake client" do
      before do
        user = Factory(:user)

        model_attributes[:author_id] = user.actor_id
        model_attributes[:user_author_id] = user.actor_id
      end

      it_should_behave_like "Deny Creating"
    end

    context "a external client" do
      before do
        @current_model = Factory(:"site/client")
      end

      it_should_behave_like "Deny Updating"
      it_should_behave_like "Deny Destroying"
    end

    context "a existing own client" do
      before do
        @current_model = Factory(:"site/client", author: @user.actor)
      end

      it "should update client" do
        put :update, :id => @current_model.to_param,
                     "client" => { name: "Update name" }

        response.should redirect_to(@current_model)
      end

      it_should_behave_like "Allow Destroying"
    end
  end
end

