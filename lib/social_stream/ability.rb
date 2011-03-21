module SocialStream
  class Ability
    include CanCan::Ability

    def initialize(user)
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
    end
  end
end
