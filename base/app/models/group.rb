# {Group Groups} are the other kind of social entities supported in SocialStream::Base
#
# As with {User}, almost all the interaction with other classes in Social Stream is done
# through {Actor}. The glue between {Group} and {Actor} is in {SocialStream::Models::Subject}
#
class Group < ActiveRecord::Base
  include SocialStream::Models::Subject

  attr_accessor :owners

  delegate :description, :description=, :to => :profile!

  after_create :create_ties

  def profile!
    actor!.profile || actor!.build_profile
  end
 
  private

  # Creates ties from founder to the group, based on _relation_ids,
  # and ties from the group to founder and owners.
  def create_ties
    create_ties_from_author
    create_ties_to_owners
  end

  # Creates the ties from the founder to the group
  def create_ties_from_author
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
  
  # Creates the ties from the group to the owners added in the group creation form
  #
  # The system-defined Relation::Owner is used for the ties
  def create_ties_to_owners
    @owners ||= ""

    owner_ids = ([ author_id, user_author_id ] | @owners.split(',').map(&:to_i)).uniq

    owner_ids.each do |a|
      c =
        sent_contacts.create! :receiver_id  => a,
                              :user_author  => user_author
      
      c.relation_ids = Array.wrap(::Relation::Owner.instance.id)
    end
  end
end
