require 'spec_helper'

describe Activity do

  describe "wall" do
    context "with a friend activity" do
      before do
        @activity = Factory(:activity)
      end

      describe "sender home" do
        it "should include activity" do
          @activity.sender.wall(:home).should include(@activity)
        end
      end

      describe "receiver home" do
        it "should include activity" do
          @activity.receiver.wall(:home).should include(@activity)
        end
      end

      describe "alien home" do
        it "should not include activity" do
          Factory(:user).wall(:home).should_not include(@activity)
        end
      end

      describe "friend's profile" do
        it "should not include activity" do
          friend = Factory(:friend, :contact => Factory(:contact, :sender => @activity.sender)).receiver
          friend.wall(:profile, :for => @activity.sender).should_not include(@activity)
        end
      end

      describe "sender profile" do
        context "for sender" do
          it "should include activity" do
            @activity.sender.wall(:profile, :for => @activity.sender).should include(@activity)
          end
        end

        context "for receiver" do
          it "should include activity" do
            @activity.sender.wall(:profile, :for => @activity.receiver).should include(@activity)
            @activity.sender.wall(:profile,
                                  :for => @activity.receiver,
                                  :relation => @activity.relations.first).should include(@activity)
          end
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
          friend.wall(:profile, :for => @activity.sender).should_not include(@activity)
        end
      end
    end

    context "with a public activity" do
      before do
        @activity = Factory(:public_activity)
      end

      describe "sender home" do
        it "should include activity" do
          @activity.sender.wall(:home).should include(@activity)
        end
      end

      describe "receiver home" do
        it "should include activity" do
          @activity.receiver.wall(:home).should include(@activity)
        end
      end

      describe "alien home" do
        it "should not include activity" do
          Factory(:user).wall(:home).should_not include(@activity)
        end
      end

      describe "sender profile" do
        context "for sender" do
          it "should include activity" do
            @activity.sender.wall(:profile, :for => @activity.sender).should include(@activity)
          end
        end

        context "for receiver" do
          it "should include activity" do
            @activity.sender.wall(:profile, :for => @activity.receiver).should include(@activity)
          end
        end

        context "for Anonymous" do
          it "should include activity" do
            @activity.sender.wall(:profile, :for => nil).should include(@activity)
          end
        end
      end

      describe "receiver profile" do
        context "for sender" do
          it "should include activity" do
            @activity.receiver.wall(:profile, :for => @activity.sender).should include(@activity)
          end
        end

        context "for receiver" do
          it "should include activity" do
            @activity.receiver.wall(:profile, :for => @activity.receiver).should include(@activity)
          end
        end

        context "for Anonymous" do
          it "should include activity" do
            @activity.receiver.wall(:profile, :for => nil).should include(@activity)
          end
        end
      end
    end
  end

  describe "to several relations" do
    before do
      @sender = Factory(:user).actor
      @friend = Factory(:friend, :contact => Factory(:contact, :sender => @sender)).receiver
      @acquaintance = Factory(:acquaintance, :contact => Factory(:contact, :sender => @sender)).receiver
    end

    it "should include timeline_actors" do
      @activity = Factory(:activity,
                          :channel => @sender.self_contact.channel,
                          :relation_ids => @sender.relation_customs.map(&:id))

      @activity.timeline_actors.should include(@friend)
      @activity.timeline_actors.should include(@acquaintance)
    end
  end
end
