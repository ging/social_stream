require 'spec_helper'

describe PicturesController do
  render_views

  context "with public picture" do
    before do
      @public_picture = Factory(:public_picture)      
    end

    describe "when not authenticated" do
      it "should redirect to login" do
        get :index  
        response.should redirect_to(:new_user_session)
      end
  
      it "should render receiver's index with public picture included" do
        get :index, :user_id => @public_picture.post_activity.receiver.to_param  
        response.should be_success
        response.body.should =~ /attachment_tile/
        response.body.should =~ /rails.png/
      end
      
      it "should render receiver's show" do
        get :show, :id => @public_picture.to_param
        response.should be_success
        response.headers["Content-Type"].should include('image/png')
      end
    end
    
    describe "when authenticated" do
      before do
        sign_in Factory(:user)
      end

      it "should render index" do
        get :index, :user_id => @public_picture.post_activity.receiver.to_param  
        response.should be_success
        response.body.should =~ /attachment_tile/
        response.body.should =~ /rails.png/
      end
      
      it "should render show" do
        get :show, :id => @public_picture.to_param
        response.should be_success
        response.headers["Content-Type"].should include('image/png')
      end
    end
  end #end of the context
  
  context "with private picture" do
    before do     
      @private_picture = Factory(:private_picture)
    end
    describe "when not authenticated" do
      it "should render receiver's index without private picture" do
        get :index, :user_id => @private_picture.post_activity.receiver.to_param  
        response.should be_success
        response.body.should_not =~ /attachment_tile/
        response.body.should_not =~ /privado.png/
      end
    end
    
    describe "when authenticated" do
      before do
        sign_in Factory(:user)
      end
      it "should render index" do
        get :index, :user_id => @private_picture.post_activity.receiver.to_param  
        response.should be_success
        response.body.should_not =~ /attachment_tile/
        response.body.should_not =~ /privado.png/
      end
      
      it "should render show" do
        lambda {get :show, :id => @private_picture.to_param}.should raise_error(CanCan::AccessDenied)
      end
    end
  end
end
