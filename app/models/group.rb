class Group < ActiveRecord::Base
  attr_accessor :_founder

  def followers
    subjects(:subject_type => :user, :direction => :senders)
  end

  after_create :create_founder

  private

  def create_founder
    sent_ties.create! :receiver => Actor.find_by_permalink!(_founder),
                      :relation => relations.sort.first
  end
end
