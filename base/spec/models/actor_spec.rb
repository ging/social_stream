require 'spec_helper'

describe Actor do
  it "should generate slug" do
    assert Factory(:user).actor.slug.present?
  end

  it "should generate different slug" do
    a = Factory(:user).actor
    b = Factory(:user, :name => a.name).actor

    a.name.should == b.name
    a.slug.should_not == b.slug
  end

  it "should generate relations" do
    assert Factory(:user).relation_customs.present?
  end

  context 'pending contacts' do
    it 'should not include self' do
      a = Factory(:user).actor
      c = a.contact_to!(a)

      a.pending_contacts.should_not include(c)
    end
  end

  it 'should generate suggestion' do
    10.times do
      Factory(:user)
    end

    sgs = Factory(:user).suggestions(5)

    sgs.size.should be(5)

    sgs_names = sgs.map{ |s| s.receiver_subject.name }.compact

    sgs.size.should be(5)
  end

  it "should be destroyed" do
    u = Factory(:user)
    a = u.actor

    u.destroy

    Actor.find_by_id(a.id).should be_nil
  end

  context "cheesecake" do
    before do
      @user = Factory(:user)
    end

    it "should build json" do
      hash = {
        :sectors => @user.relation_customs.map do |r|
          { :id => r.id, :name => r.name,
            :subsectors => [ { :id => r.id, :name => r.name, :actors => [] } ]
          }
        end
      }

      @user.cheesecake_json.should eq(hash.to_json)
    end

    context "with tie" do
      before do
        @tie =
          Factory(:friend, :contact => Factory(:contact, :sender => @user.actor))
      end

      it "should render json" do
        @user.cheesecake_json.should include(@tie.receiver.id.to_s)
      end
    end
  end
end
