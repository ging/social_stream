require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Representation do
  describe "initialized with" do
    describe "valid subject" do
      before do
        @group  = Factory(:group)
        @dom_id = ActionController::RecordIdentifier.dom_id(@group)
      end

      it "should find subject" do
        assert_equal @group, Representation.new(:subject_dom_id => @dom_id).subject
      end
    end
  end
end
