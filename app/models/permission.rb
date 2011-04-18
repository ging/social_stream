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
# Function is a novel feature. It supports applying the permission to other related ties.
# It is required because the set of ties changes along with the establish of contacts
# in the website, besides {SocialStream::Models::Subject subjects} can describe and
# customize their own relations and permissions.
#
# Available functions are:
#
# nil:: apply the permission to the established tie only.
#
#         Example: if the _friend_ relation has the permission
#         <tt>create activity nil</tt>, the _friend_ can create activities
#         attached to this tie only. _Bob_ can create activities only at _Alice_'s
#         _friend_ level.
#
# +weak_ties+:: apply the permission to all the related ties with a relation weaker
#               or equal than this. When a subject establishes a strong ties,
#               their related ties are established at the same time.
#
#               Example: if the _member_ relation of a group has the permission
#               <tt>create activity weak_ties</tt>, its members
#               can also create activities attached to the weaker ties of
#               _acquaintance_ and _public_.
#               This means than a group _member_ can create activities at different
#               levels of strength hierarchy, and therefore, with different levels of
#               access.
#
# +star_ties+:: the permission applies to all the ties at the same level of strength,
#               that is, ties with the same sender and the same relation but
#               different receivers.
#
#               Example: the _public_ relation has the permission
#               <tt>read activity star_ties</tt>. If _Alice_ has a _public_ tie with
#               _Bob_, she is granting him access to activities attached to other ties
#               from _Alice_ to the rest of her _public_ contacts.
#
# +weak_star_ties+:: apply the permission to weak and star ties. This is the union of
#                    the former.
#            
#                    Example: group's _admin relation has the permission
#                    <tt>destroy activity weak_star_ties</tt>
#                    This means that _admins_ can destroy activities from other
#                    _members_, _acquaintances_ and _public_.
#
class Permission < ActiveRecord::Base
  has_many :relation_permissions, :dependent => :destroy
  has_many :relations, :through => :relation_permissions

  %w(represent follow).each do |p|
    scope p, where(:action => p) # scope :represent, where(:action => 'represent')
  end

  # The SQL and ARel conditions for permission queries
  ParameterConditions = {
    :table => {
      nil =>
        "ties_as.sender_id = ties.sender_id AND ties_as.receiver_id = ties.receiver_id AND ties_as.relation_id = ties.relation_id",
      'weak_ties' =>
        "ties_as.sender_id = ties.sender_id AND ties_as.receiver_id = ties.receiver_id AND (relations.id = relations_as.id OR relations.ancestry = relations_as.id OR relations.ancestry = (relations_as.ancestry || '/' || relations_as.id) OR relations.ancestry LIKE (relations_as.id || '/%') OR relations.ancestry LIKE (relations_as.ancestry || '/' || relations_as.id || '/%'))",
      'star_ties' =>
        "ties_as.sender_id = ties.sender_id AND ties_as.relation_id = ties.relation_id",
      'weak_star_ties' =>
        "ties_as.sender_id = ties.sender_id AND (relations.id = relations_as.id OR relations.ancestry = relations_as.id OR relations.ancestry = (relations_as.ancestry || '/' || relations_as.id) OR relations.ancestry LIKE (relations_as.id || '/%') OR relations.ancestry LIKE (relations_as.ancestry || '/' || relations_as.id || '/%'))"
    },
    :arel => {
      nil => lambda { |as, t|
        # The same sender, receiver and relation
        as[:sender_id].eq(t.sender_id).and(
          as[:receiver_id].eq(t.receiver_id)).and(
          as[:relation_id].eq(t.relation_id))
      },
      'weak_ties' => lambda { |as, t|
        # The same sender and receiver, but a stronger or equal relation
        as[:sender_id].eq(t.sender_id).and(
          as[:receiver_id].eq(t.receiver_id)).and(
          as[:relation_id].in(t.relation.stronger_or_equal.map(&:id)))
      },
      'star_ties' => lambda { |as, t|
        # The same receiver and relation
        as[:sender_id].eq(t.sender_id).and(
          as[:relation_id].eq(t.relation_id))
      },
      'weak_star_ties' => lambda { |as, t|
        # The same receiver with stronger or equal relations
        as[:sender_id].eq(t.sender_id).and(
          as[:relation_id].in(t.relation.stronger_or_equal.map(&:id)))
      }
    }
  }

  class << self
    # Builds SQL conditions based on {ParameterConditions}
    def parameter_conditions(tie = nil)
      if tie.present?
        ParameterConditions[:arel].inject([]) { |conditions, h|
          # Add the condition 'permissions.function = key'
          # to all arel ParameterConditions
          conditions <<
            h.last.call(Tie.arel_table, tie).and(arel_table[:function].eq(h.first))
        }.inject(nil){ |result, pc|
          # Join all ParameterConditions with OR
          result.nil? ? pc : result.or(pc)
        }
      else
        ParameterConditions[:table].inject([]){ |result, pc|
          result <<
            "#{ pc.last } AND #{ sanitize_sql('permissions.function' => pc.first) }"
        }.join(" OR ")
      end
    end
  end
end
