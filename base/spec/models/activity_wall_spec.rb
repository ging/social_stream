require 'spec_helper'

describe Activity do

  context "user" do
    before(:all) do
      @subject = @user = Factory(:user)
    end

    context "with public activity" do
      before do
        @activity = Factory(:self_activity, :relation_ids => [Relation::Public.instance.id])
      end

      describe "sender home" do
        it "should include activity" do
          @activity.sender.wall(:home).should include(@activity)
        end
      end

      describe "sender profile" do
        context "accessed by alien" do
          it "should include activity" do
            @activity.sender.wall(:profile,
                                  :for => Factory(:user)).should include(@activity)
          end
        end

        context "accessed by anonymous" do
          it "should include activity" do
            @activity.sender.wall(:profile,
                                  :for => nil).should include(@activity)
          end
        end
      end
    end

    describe "belonging to friend" do
      before do
        @activity = Factory(:activity)
      end

      describe "sender home" do
        it "should include activity" do
          @activity.sender.wall(:home).should include(@activity)
        end
      end

      describe "sender profile" do
        context "accessed by friend" do
          it "should include activity" do
            @activity.sender.wall(:profile,
                                  :for => @activity.receiver).should include(@activity)
          end
        end

        context "accessed by alien" do
          it "should not include activity" do
            @activity.sender.wall(:profile,
                                  :for => Factory(:user)).should_not include(@activity)
          end
        end

        context "accessed by anonymous" do
          it "should not include activity" do
            @activity.sender.wall(:profile,
                                  :for => nil).should_not include(@activity)
          end
        end
      end

      describe "receiver profile" do
        context "accessed by receiver" do
          it "should include activity" do
            @activity.receiver.wall(:profile,
                                    :for => @activity.receiver).should include(@activity)
          end
        end

        context "accessed by alien" do
          it "should not include activity" do
            @activity.receiver.wall(:profile,
                                    :for => Factory(:user)).should_not include(@activity)
          end
        end

        context "accessed by anonymous" do
          it "should not include activity" do
            @activity.receiver.wall(:profile,
                                    :for => nil).should_not include(@activity)
          end
        end
      end
    end
  end
end
