class Group < ActiveRecord::Base
  attr_accessor :_founder
  attr_accessor :_participants

  def followers
    subjects(:subject_type => :user, :direction => :senders)
  end

  after_create :create_founder
  after_create :create_participants
  
  
  private

  #Creates the ties betwbeen the group and the founder
  def create_founder
    founder =
      Actor.find_by_permalink(_founder) || raise("Cannot create group without founder")

    sent_ties.create! :receiver => founder,
                      :relation => relations.sort.first
  end
  
  #Creates the ties betwbeen the group and the participants
  def create_participants
    
     return if @_participants.blank?
    
     @_participants.each do |participant|
      
      participantActor = Actor.find_by_id(participant.to_i)
      sent_ties.create! :receiver => participantActor,
                        :relation => relations.sort.first
     end
    
  end
  
end