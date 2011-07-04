require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContactsController do

  render_views

  before(:all) do
    @tie = Factory(:friend)
    @user = @tie.sender_subject
  end

  it "should be successful" do
    sign_in @user

    get 'index'
    response.should be_success
  end

  it "should render edit" do
    sign_in @user

    get :edit, :id => @tie.contact_id

    assert_response :success
  end

  it "should render update" do
    sign_in @user

    put :update, :id => @tie.contact_id,
                 :contact => { "relation_ids" => [ "gotcha", @user.relations.last.id ] }

    response.should redirect_to(@tie.receiver_subject)
    @user.reload.
      sent_ties.
      merge(Contact.received_by(@tie.receiver)).
      first.relation.
      should == @user.relations.last
  end

  it "should create contact" do
    sign_in @user

    group = Factory(:group)
    contact = @user.contact_to!(group)
    

    put :update, :id => contact.id,
                 :contact => { :relation_ids => [ "gotcha", @user.relations.last.id ],
                               :message => "Testing" }

    response.should redirect_to(contact.receiver_subject)
    contact.reload.
      ties.
      first.relation.
      should == @user.relations.last
  end

end
