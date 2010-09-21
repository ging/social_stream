require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tie do
  describe "with a relation with inverse" do
    before do
      @relation = Relation.where("inverse_id IS NOT NULL").first
    end

    it "should have its inverse tie" do
      @tie = Factory(:tie, :relation => @relation)

      assert Tie.find_by_sender_id_and_receiver_id_and_relation_id(@tie.receiver_id,
                                                                   @tie.sender_id,
                                                                   @relation.inverse).present?
    end
  end
end

