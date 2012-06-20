require 'spec_helper'

describe Activity do
  before(:all) do
    @activity = Factory(:activity)
  end

  it "should be destroyed along with its author" do
    author = @activity.author

    author.destroy

    Activity.find_by_id(@activity.id).should be_nil
  end
end
