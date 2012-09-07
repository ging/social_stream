require 'spec_helper'

describe Relation do
  context "authorization" do
    before(:all) do
      @tie = Factory(:friend)
      @relation = @tie.relation
    end

    describe ", receiver" do
      before do
        @s = @tie.receiver
      end

      it "creates activity" do
        Relation.allow(@s, 'create', 'activity').should include(@relation)
      end

      it "reads activity" do
        Relation.allow(@s, 'read', 'activity').should include(@relation)
      end
    end

    describe ", acquaintance" do
      before do
        @s = Factory(:acquaintance, :contact => Factory(:contact, :sender => @tie.sender)).receiver
      end

      it "creates activity" do
        Relation.allow(@s, 'create', 'activity').should_not include(@relation)
      end

      it "reads activity" do
        Relation.allow(@s, 'read', 'activity').should_not include(@relation)
      end
    end

    describe ", alien" do
      before do
        @s = Factory(:user)
      end

      it "creates activity" do
        Relation.allow(@s, 'create', 'activity').should_not include(@relation)
      end
      
      it "reads activity" do
        Relation.allow(@s, 'read', 'activity').should_not include(@relation)
      end
    end
  end

  describe "member" do
    before do
      @tie = Factory(:member)
      @relation = @tie.relation
    end

    describe ", member" do
      before do
        @s = Factory(:member, :contact => Factory(:contact, :sender => @tie.sender)).receiver
      end

      it "creates activity" do
        Relation.allow(@s, 'create', 'activity').should include(@relation)
      end

       it "reads activity" do
        Relation.allow(@s, 'read', 'activity').should include(@relation)
      end

      it "updates activity" do
        Relation.allow(@s, 'update', 'activity').should_not include(@relation)
      end
    end
  end

  describe 'with follow permission' do
    before do
      @relation = Relation.create!
      @relation.permissions << Permission.find_or_create_by_action('follow')
    end

    it 'should follow?' do
      @relation.follow?.should be_true
    end
  end

  describe 'without follow permission' do
    before do
      @relation = Relation.create!
    end

    it 'should follow?' do
      @relation.follow?.should be_false
    end
  end

end

