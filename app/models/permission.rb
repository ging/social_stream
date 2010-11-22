class Permission < ActiveRecord::Base
  has_many :relation_permissions, :dependent => :destroy
  has_many :relations, :through => :relation_permissions

  ParameterConditions = {
    :table => {
      'tie' =>
        "ties_as.sender_id = ties.sender_id AND ties_as.receiver_id = ties.receiver_id AND ties_as.relation_id = ties.relation_id",
      'weak_set' =>
        "ties_as.sender_id = ties.sender_id AND ties_as.receiver_id = ties.receiver_id AND relations.lft BETWEEN relations_as.lft AND relations_as.rgt",
      'inverse_weak_set' =>
        "ties_as.sender_id = ties.receiver_id AND ties_as.receiver_id = ties.sender_id AND relations.inverse_id = relations_inverse.id AND relations_inverse.lft BETWEEN relations_as.lft AND relations_as.rgt",
      'group_set' =>
        "ties_as.receiver_id = ties.receiver_id AND ties_as.relation_id = ties.relation_id",
      'inverse_group_set' =>
        "ties_as.sender_id = ties.receiver_id AND ties_as.relation_id = relations.inverse_id",
      'weak_group_set' =>
        "ties_as.receiver_id = ties.receiver_id AND relations.lft BETWEEN relations_as.lft AND relations_as.rgt",
      'inverse_weak_group_set' =>
        "ties_as.sender_id = ties.receiver_id AND relations.inverse_id = relations_inverse.id AND relations_inverse.lft BETWEEN relations_as.lft AND relations_as.rgt"
    },
    :arel => {
      'tie' => lambda { |as, t|
        # The same sender, receiver and relation
        as[:sender_id].eq(t.sender_id).and(
          as[:receiver_id].eq(t.receiver_id)).and(
          as[:relation_id].eq(t.relation_id))
      },
      'weak_set' => lambda { |as, t|
        # The same sender and receiver, but a stronger or equal relation
        as[:sender_id].eq(t.sender_id).and(
          as[:receiver_id].eq(t.receiver_id)).and(
          as[:relation_id].in(t.relation.stronger_or_equal.map(&:id)))
      },
      'inverse_weak_set' => lambda { |as, t|
        # Senders and receivers interchanged, with a stronger or equal relation of the inverse
        as[:sender_id].eq(t.receiver_id).and(
          as[:receiver_id].eq(t.sender_id)).and(
          as[:relation_id].in(Array(t.relation.inverse.try(:stronger_or_equal)).map(&:id)))
      },
      'group_set' => lambda { |as, t|
        # The same receiver and relation
        as[:receiver_id].eq(t.receiver_id).and(
          as[:relation_id].eq(t.relation_id))
      },
      'inverse_group_set' => lambda { |as, t|
        # Senders to the common receiver in the same relation
        as[:sender_id].eq(t.receiver_id).and(
          as[:relation_id].eq(t.relation.inverse_id))
      },
      'weak_group_set' => lambda { |as, t|
        # The same receiver with stronger or equal relations
        as[:receiver_id].eq(t.receiver_id).and(
          as[:relation_id].in(t.relation.stronger_or_equal.map(&:id)))
      },
      'inverse_weak_group_set' => lambda { |as, t|
        # Senders to the common receiver with stronger or equal relations
        as[:sender_id].eq(t.receiver_id).and(
          as[:relation_id].in(Array(t.relation.inverse.try(:stronger_or_equal)).map(&:id)))
      }
    }
  }

  class << self
    def parameter_conditions(tie = nil)
      if tie.present?
        ParameterConditions[:arel].inject([]) { |conditions, h|
          # Add the condition 'permissions.parameter = key'
          # to all arel ParameterConditions
          conditions <<
            h.last.call(Tie.arel_table, tie).and(arel_table[:parameter].eq(h.first))
        }.inject(nil){ |result, pc|
          # Join all ParameterConditions with OR
          result.nil? ? pc : result.or(pc)
        }
      else
        ParameterConditions[:table].inject([]){ |result, pc|
          result <<
            sanitize_sql([ "#{ pc.last } AND permissions.parameter = ?", pc.first ])
        }.join(" OR ")
      end
    end
  end
end
