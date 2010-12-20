module SocialStream
  class Ability
    include CanCan::Ability

    def initialize(user)
      can :create, Activity do |a|
        # All ties' authors must be the user
        a.tie.receiver_subject == user &&
          a.tie.allow?(user, 'create', 'activity')
      end

      can :read, Activity do |a|
        # This condition would not be neccesary if every actor had a public tie with others
        a.tie.relation.name == 'public' ||
          a.tie.allow?(user, 'read', 'activity')
      end

      can :update, Activity do |a|
        a.tie.allow?(user, 'update', 'activity')
      end

      can :destroy, Activity do |a|
        a.tie.allow?(user, 'destroy', 'activity')
      end
    end
  end
end
