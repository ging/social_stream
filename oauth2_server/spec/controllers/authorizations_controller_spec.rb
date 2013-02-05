require 'spec_helper'

describe AuthorizationsController do
  let(:redirect_uri) { "https://test.host/callback" }
  let(:token) { "token" }

  let(:authorization_code) { double :authorization_code, token: token }
  let(:user) { double :user, language: :en }
  let(:client) { double :client, callback_url: redirect_uri }

  context "#new" do
    context "without authentication" do
      it "should redirect to login" do
        get :new

        response.should redirect_to(:new_user_session)
      end
    end

    context "with authentication" do
      before do
        controller.stub(:authenticate_user!)
        controller.stub(:current_user) { user }
      end

      context "without client_id" do
        it "should respond with bad request" do
          get :new

          response.should be_bad_request
          assigns(:error).to_s.should eq('bad_request')
        end
      end

      context "with client_id" do
        before :each do
          @params = { client_id: 7 }
        end

        it "should return bad request" do
          get :new, @params

          response.should be_bad_request
          assigns(:error).to_s.should eq("invalid_request :: 'response_type' required.")
        end

        context "with response code" do
          before :each do
            @params.merge! response_type: 'code'
          end

          it "should raise RecordNotFound" do
            lambda { get :new, @params }.should raise_error(ActiveRecord::RecordNotFound)
          end

          context "with valid client" do
            before do
              Site::Client.should_receive(:find).with("7") { client }
            end

            context "not authorized" do
              before do
                user.stub(:client_authorized?) { false }
              end

              it "should render new" do
                get :new, @params

                response.should be_success
                response.should render_template('new')
              end
            end

            context "authorized" do
              before do
                user.stub(:client_authorized?) { true }

                codes = double(:codes)

                user.stub(:authorization_codes) { codes }

                codes.should_receive(:create!).with(client: client, redirect_uri: redirect_uri) { authorization_code }
              end

              it "should render new" do
                get :new, @params

                response.should redirect_to("#{ redirect_uri }?code=#{ token }")
              end
            end
          end
        end
      end
    end
  end

  describe "#create" do 
    context "without authentication" do
      it "should redirect to login" do
        post :create

        response.should redirect_to(:new_user_session)
      end
    end

    describe "with authentication" do
      before do
        controller.stub(:authenticate_user!)
        controller.stub(:current_user) { user }
      end

      context "without client_id" do
        it "should respond with bad request" do
          post :create

          response.should be_bad_request
          assigns(:error).to_s.should eq('bad_request')
        end
      end

      context "with client_id" do
        before :each do
          @params = { client_id: 7 }
        end

        it "should return bad request" do
          post :create, @params

          response.should be_bad_request
          assigns(:error).to_s.should eq("invalid_request :: 'response_type' required.")
        end

        context "with response code" do
          before :each do
            @params.merge! response_type: 'code'
          end

          it "should raise RecordNotFound" do
            lambda { post :create, @params }.should raise_error(ActiveRecord::RecordNotFound)
          end

          context "with valid client" do
            before do
              Site::Client.should_receive(:find).with("7") { client }
            end

            context "not accepted" do
              it "should redirect" do
                post :create, @params

                response.should redirect_to("#{ redirect_uri }?error=access_denied&error_description=The+end-user+or+authorization+server+denied+the+request.")
              end
            end

            context "accepted" do
              before do
                @params.merge!(accept: "true")

                user.should_receive(:client_authorize!).with(client)

                codes = double(:codes)

                user.stub(:authorization_codes) { codes }

                codes.should_receive(:create!).with(client: client, redirect_uri: redirect_uri) { authorization_code }
              end

              it "should respond with test" do
                post :create, @params

                response.should redirect_to("#{ redirect_uri }?code=#{ token }")
              end
            end
          end
        end
      end
    end
  end
end
