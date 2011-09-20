require 'spec_helper'

describe DocumentsController do
  render_views

  context "with public document" do
    before do
      @public_document = Factory(:public_document)      
    end

    describe "when not authenticated" do
      it "should redirect to login" do
        get :index  
        response.should redirect_to(:new_user_session)
      end
  
      it "should render receiver's index with public document included" do
        get :index, :user_id => @public_document.post_activity.receiver.to_param  
        response.should be_success
        response.body.should =~ /attachment_tile/
        response.body.should =~ /small.pdf/
      end
      
      it "should render receiver's show" do
        get :show, :id => @public_document.to_param
        response.should be_success
        response.headers["Content-Type"].should include('application/pdf')
      end
    end
    
    describe "when authenticated" do
      before do
        sign_in Factory(:user)
      end

      it "should render index" do
        get :index, :user_id => @public_document.post_activity.receiver.to_param  
        response.should be_success
        response.body.should =~ /attachment_tile/
        response.body.should =~ /small.pdf/
      end
      
      it "should render show" do
        get :show, :id => @public_document.to_param
        response.should be_success
        response.headers["Content-Type"].should include('application/pdf')
      end
    end
  end #end of the context
  
  context "with private document" do
    before do     
      @private_document = Factory(:private_document)
    end
    describe "when not authenticated" do
      it "should render receiver's index without private document" do
        get :index, :user_id => @private_document.post_activity.receiver.to_param  
        response.should be_success
        response.body.should_not =~ /attachment_tile/
        response.body.should_not =~ /small.pdf/
      end
    end
    
    describe "when authenticated" do
      before do
        sign_in Factory(:user)
      end
      it "should render index" do
        get :index, :user_id => @private_document.post_activity.receiver.to_param  
        response.should be_success
        response.body.should_not =~ /attachment_tile/
        response.body.should_not =~ /small.pdf/
      end
      
      it "should render show" do
        lambda {get :show, :id => @private_document.to_param}.should raise_error(CanCan::AccessDenied)
      end
    end
  end
end
