require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TieActivity do
  describe "dissemination" do
    context "a friend b" do
      before do
        @afb = Factory(:friend)
      end

      context "c friend a" do
        before do
          @cfa = Factory(:friend, :receiver => @afb.sender)
          @a = Factory(:activity, :_tie => @afb)
        end

        it "should not be created" do
          @cfa.activities.should_not include(@a)
        end

        context "and a friend c" do
          before do
            @afc = Factory(:friend, :sender => @cfa.receiver, :receiver => @cfa.sender)
            @a = Factory(:activity, :_tie => @afb)
          end

          it "should be created" do
            @cfa.activities.should include(@a)
          end

        end
      end

      context "and d friend b" do
        before do
          @dfb = Factory(:friend, :receiver => @afb.receiver)
          @a = Factory(:activity, :_tie => @afb)
        end

        it "should not be created" do
          @dfb.activities.should_not include(@a)
        end

        context "and b friend d" do
          before do
            @bfd = Factory(:friend, :sender => @dfb.receiver, :receiver => @dfb.sender)
            @a = Factory(:activity, :_tie => @afb)
          end

          it "should not be created" do
            @dfb.activities.should_not include(@a)
          end
        end

      end

      context "and b friend a" do
        before do
          @bfa = Factory(:friend, :sender => @afb.receiver, :receiver => @afb.sender)
        end

        context "c friend a" do
          before do
            @cfa = Factory(:friend, :receiver => @afb.sender)
            @a = Factory(:activity, :_tie => @afb)
          end

          it "should not be created" do
            @cfa.activities.should_not include(@a)
          end

          context "and a friend c" do
            before do
              @afc = Factory(:friend, :sender => @cfa.receiver, :receiver => @cfa.sender)
              @a = Factory(:activity, :_tie => @afb)
            end

            it "should be created" do
              @cfa.activities.should include(@a)
            end

          end
        end

        context "and d friend b" do
          before do
            @dfb = Factory(:friend, :receiver => @afb.receiver)
            @a = Factory(:activity, :_tie => @afb)
          end

          it "should not be created" do
            @dfb.activities.should_not include(@a)
          end

          context "and b friend d" do
            before do
              @bfd = Factory(:friend, :sender => @dfb.receiver, :receiver => @dfb.sender)
              @a = Factory(:activity, :_tie => @afb)
            end

            it "should be created" do
              @dfb.activities.should include(@a)
            end
          end
        end
      end
    end
  end
end

