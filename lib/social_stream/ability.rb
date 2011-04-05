module SocialStream
  class Ability
    include CanCan::Ability

    def initialize(user)
      # Activity Objects
      (SocialStream.objects - [ :actor ]).map{ |obj|
        obj.to_s.classify.constantize
      }.each do |klass|
        can :create, klass do |k|
          k._activity_tie.allows?(user, 'create', 'activity')
        end

        can :read, klass do |k|
          k._activity_tie.allows?(user, 'read', 'activity')
        end

        can :update, klass do |k|
          k._activity_tie.allows?(user, 'update', 'activity')
        end

        can :destroy, klass do |k|
          k._activity_tie.allows?(user, 'destroy', 'activity')
        end
      end

      # Activities
      can :create, Activity do |a|
        a.tie.allows?(user, 'create', 'activity')
      end

      can :read, Activity do |a|
        a.tie.allows?(user, 'read', 'activity')
      end

      can :update, Activity do |a|
        a.tie.allows?(user, 'update', 'activity')
      end

      can :destroy, Activity do |a|
        a.tie.allows?(user, 'destroy', 'activity')
      end

      # Groups
      can :read, Group

      can :create, Group do |g|
        user.present? &&
          ( g._founder == user.slug ||
            Actor.find_by_slug!(g._founder).sent_ties.received_by(user).with_permissions('represent', nil).any? )
      end

      can :update, Group do |g|
        user.present? &&
          g.sent_ties.received_by(user).with_permissions('represent', nil).any?
      end

      can :destroy, Group do |g|
        user.present? &&
          g.sent_ties.received_by(user).with_permissions('represent', nil).any?
      end
    end
  end
end
