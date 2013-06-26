# SocialStream provides a system of permissions based on the {Relation relations}
# of the social network as roles.
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
# Permissions are composed by *action* and *object*. Action and object
# are typical in content management systems, e.g. <tt>create activity</tt>,
# <tt>update tie</tt>, <tt>read post</tt>.
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
# Other objects currently not implemented could be +tie+, +post+, +comment+ or +message+
#
#
class Permission < ActiveRecord::Base
  has_many :relation_permissions, :dependent => :destroy
  has_many :relations, :through => :relation_permissions

  %w(represent follow).each do |p|
    scope p, where(:action => p) # scope :represent, where(:action => 'represent')
  end

  class << self
    # Finds or creates in the database the instances of the permissions described in
    # {ary} by arrays of [ action, object ]
    def instances ary
      ary.map{ |p| find_or_create_by_action_and_object *p }
    end
  end

  # The permission title
  def title(options = {})
    i18n_description :brief, options
  end

  # The permission description
  def description(options = {})
    i18n_description :detailed, options
  end

  private

  # An explanation of the permissions. Type can be brief or detailed.
  # If detailed, description includes more information about the relation
  def i18n_description(type, options = {})
    unless options[:subject].present?
      raise "Now we need subject for permission description"
    end

    options[:name] = options[:subject].name

    prefix = "permission.description"
    suffix = "#{ type }.#{ action }.#{ object || "nil" }"

    if options[:state]
      suffix += ".#{ options[:state] }"
    end

    options[:default] = :"#{ prefix }.default.#{ suffix }"

    I18n.t "#{ prefix }.#{ options[:subject].subject_type.underscore }.#{ suffix }",
           options
  end
end
