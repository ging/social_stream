# {Group Groups} are the other kind of social entities supported in SocialStream::Base
#
# As with {User}, almost all the interaction with other classes in Social Stream is done
# through {Actor}. The glue between {Group} and {Actor} is in {SocialStream::Models::Subject}
#
class Group < ActiveRecord::Base
  include SocialStream::Models::Subject

  attr_accessor :_participants

  delegate :description, :description=, :to => :profile!

  after_create :create_ties

  def profile!
    actor!.profile || actor!.build_profile
  end
 
  private

  # Creates ties from founder to the group, based on _relation_ids,
  # and ties from the group to founder and participants.
  def create_ties
    create_ties_from_founder
    create_ties_to_participants
  end

  # Creates the ties from the founder to the group
  def create_ties_from_founder
=begin
    # FIXME: need to define a proper relation for this case. Maybe a system defined relation
    author.sent_contacts.create! :receiver_id  => actor_id,
                                 :relation_ids => _relation_ids

    if represented_author?
      user_author.sent_contacts.create! :receiver_id  => actor_id,
                                        :relation_ids => _relation_ids
    end
=end
  end
  
  # Creates the ties from the group to the participants
  def create_ties_to_participants
    @_participants ||= ""

    participant_ids = ([ author_id, user_author_id ] | @_participants.split(',').map(&:to_i)).uniq

    participant_ids.each do |a|
      c =
        sent_contacts.create! :receiver_id  => a,
                              :user_author  => user_author
      
      c.relation_ids = Array.wrap(relation_customs.sort.first.id)
    end
  end
end
