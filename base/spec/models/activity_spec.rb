require 'spec_helper'

describe Activity do

  describe "wall" do
    context "with a friend activity" do
      before do
        @activity = Factory(:activity)
      end

      describe "sender home" do
        it "should include activity" do
          Activity.timeline(:home, @activity.sender).should include(@activity)
        end
      end

      describe "receiver home" do
        it "should include activity" do
          Activity.timeline(:home, @activity.receiver).should include(@activity)
        end
      end

      describe "alien home" do
        it "should not include activity" do
          Activity.timeline(:home, Factory(:user)).should_not include(@activity)
        end
      end

      describe "friend's profile" do
        it "should not include activity" do
          friend = Factory(:friend, :contact => Factory(:contact, :sender => @activity.sender)).receiver
          Activity.timeline(friend, @activity.sender).should_not include(@activity)
        end
      end

      describe "sender profile" do
        context "for sender" do
          it "should include activity" do
            Activity.timeline(@activity.sender, @activity.sender).should include(@activity)
          end
        end

        context "for receiver" do
          it "should include activity" do
            Activity.timeline(@activity.sender, @activity.receiver).should include(@activity)
          end
        end
      end

      describe "public timeline" do
        it "should not include activity" do
          Activity.timeline.should_not include(@activity)
        end
      end
    end

    context "with a self friend activity" do
      before do
        @activity = Factory(:self_activity)
      end

      describe "friend's profile" do
        it "should not include activity" do
          friend = Factory(:friend, :contact => Factory(:contact, :sender => @activity.sender)).receiver
          Activity.timeline(friend, @activity.sender).should_not include(@activity)
        end
      end

      describe "public timeline" do
        it "should not include activity" do
          Activity.timeline.should_not include(@activity)
        end
      end
    end

    context "with a public activity" do
      before do
        @activity = Factory(:public_activity)
      end

      describe "sender home" do
        it "should include activity" do
          Activity.timeline(:home, @activity.sender).should include(@activity)
        end
      end

      describe "receiver home" do
        it "should include activity" do
          Activity.timeline(:home, @activity.receiver).should include(@activity)
        end
      end

      describe "alien home" do
        it "should not include activity" do
          Activity.timeline(:home, Factory(:user)).should_not include(@activity)
        end
      end

      describe "sender profile" do
        context "for sender" do
          it "should include activity" do
            Activity.timeline(@activity.sender, @activity.sender).should include(@activity)
          end
        end

        context "for receiver" do
          it "should include activity" do
            Activity.timeline(@activity.sender, @activity.receiver).should include(@activity)
          end
        end

        context "for Anonymous" do
          it "should include activity" do
            Activity.timeline(@activity.sender, nil).should include(@activity)
          end
        end
      end

      describe "receiver profile" do
        context "for sender" do
          it "should include activity" do
            Activity.timeline(@activity.receiver, @activity.sender).should include(@activity)
          end
        end

        context "for receiver" do
          it "should include activity" do
            Activity.timeline(@activity.receiver, @activity.receiver).should include(@activity)
          end
        end

        context "for Anonymous" do
          it "should include activity" do
            Activity.timeline(@activity.receiver, nil).should include(@activity)
          end
        end
      end

      describe "public timeline" do
        it "should include activity" do
          Activity.timeline.should include(@activity)
        end
      end
    end
  end
end
