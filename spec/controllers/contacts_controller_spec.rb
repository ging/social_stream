require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContactsController do

  render_views

  before do
    sign_in Factory(:friend).sender_subject
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "when authenticated" do
    before do
      @user = Factory(:user)

      sign_in @user
    end

    it "should render edit" do
      get :edit, :id => Factory(:user).actor_id

      assert_response :success
    end

    it "should render update" do
      contact = Factory(:user)

      put :update, :id => contact.actor_id,
                   :contact => { "relation_ids" => [ "gotcha", @user.relations.first.id ] }

      response.should redirect_to(contact)
      @user.sent_ties.received_by(contact).first.relation.should == @user.relations.first
    end
  end
end
