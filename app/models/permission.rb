# SocialStream provides a sophisticated and powerful system of permissions based on the {Relation relations}
# of the social network.
#
# = Permissions and Relations
#
# Permissions are assigned to {Relation Relations}, and through relations, to {Tie Ties}. 
# When a sender establishes a {Tie} with a receiver, she is granting to the receiver
# the permissions assigned to {Relation} of the {Tie} she has just established.
#
# For example, when _Alice_ establishes a _friend_ tie to _Bob_, she is granting
# him the permissions associated with her _friend_ relation. Alice's _friend_ relation may
# have different permissions from Bob's _friend_ relation.
#
# = Permissions description
#
# Permissions are composed by *action*, *objective* and *function*. Action and objective
# are typical in content management systems, e.g. <tt>create activity</tt>,
# <tt>update tie</tt>, <tt>read post</tt>. *function* is a new parameter for social networks
#
# == Actions
#
# Current available actions are:
#
# +create+:: add a new instance of something (activity, tie, post, etc)
# +read+::   view something
# +update+::  modify something
# +destroy+:: delete something
# +follow+::  subscribe to activity updates from the receiver of the tie
# +represent+:: give the receiver rights to act as if he were me.
#
# == Objectives
#
# +activity+:: all the objects in a wall: posts, comments
#
# Other objectives currently not implemented could be +tie+, +post+, +comment+ or +message+
#
# == Functions
#
# Function is a novel feature. It supports applying the permission to other related relations and ties.
# It is required because the set of ties changes while {SocialStream::Models::Subject subjects } build their network. 
# Besides {SocialStream::Models::Subject subjects} can describe and
# customize their own relations and permissions.
#
# Available functions are:
#
# +same_level+:: the permission applies to all the objects in same relation
#
#               Example: the _friend_ relation has the permission
#               <tt>read tie same_level</tt>. If _Alice_ has a _friend_ tie with
#               _Bob_, she is granting him access to read all the contacts of type _friend_
##
# +same_and_lower_levels+:: apply the permission to all the related objects attached to a relation weaker
#               or equal than this.#
#
#               Example: if the _member_ relation of a group has the permission
#               <tt>create activity same_and_lower_levels</tt>, its members
#               can also create activities attached to the weaker relations of
#               _acquaintance_ and _public_.
#               This means than a group _member_ can create activities at different
#               levels of the sphere, and therefore, with different levels of
#               access.
#
class Permission < ActiveRecord::Base
  has_many :relation_permissions, :dependent => :destroy
  has_many :relations, :through => :relation_permissions

  %w(represent follow).each do |p|
    scope p, where(:action => p) # scope :represent, where(:action => 'represent')
  end

  RelationConditions = {
    'same_level' =>
        "relations.id = relations_as.id",
    'same_and_lower_levels' =>
      "(relations.id = relations_as.id OR relations.ancestry = relations_as.id || '' OR relations.ancestry = (relations_as.ancestry || '/' || relations_as.id) OR relations.ancestry LIKE (relations_as.id || '/%') OR relations.ancestry LIKE (relations_as.ancestry || '/' || relations_as.id || '/%')) OR (relations.actor_id = relations_as.actor_id AND relations.type = 'Relation::Public')"
  }

  class << self
    # Builds SQL conditions based on {RelationConditions}
    def relation_conditions
      RelationConditions.inject([]){ |result, pc|
        result <<
          "(#{ pc.last }) AND #{ sanitize_sql('permissions_as.function' => pc.first) }"
      }.join(" OR ")
    end
  end

  # An explanation of the permissions. Type can be brief or detailed.
  # If detailed, description includes details about the relation
  def description(type, relation = nil)
    options = ( relation.present? ? description_options(relation) : {} )

    I18n.t "permission.description.#{ type }.#{ action }.#{ object || "nil" }.#{ function || "nil" }",
           options
  end

  private

  def description_options(relation)
    { 
      :sphere => relation.sphere.name,
      :public => I18n.t('relation_public.name')
    }.tap do |h|
      case function
      when NilClass, "star_ties"
        h[:relation] = relation.name
      when "weak_ties", "weak_star_ties"
        h[:relations] = relation.
                        weaker_or_equal.
                        sort.
                        map(&:name).
                        join(", ")

      end
    end

  end
end
