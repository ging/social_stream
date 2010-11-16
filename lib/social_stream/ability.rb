module SocialStream
  class Ability
    include CanCan::Ability

    def initialize(user)
      can :create, Activity do |a|
        # All ties authors must the user
        a.tie.sender_subject == user &&
          a.tie.permission?(user, 'create', 'activity')
      end

      can :read, Activity do |a|
        a.tie.relation.name == 'public' ||
          a.tie.permission?(user, 'read', 'activity')
      end

      can :update, Activity do |a|
        a.tie.permission?(user, 'update', 'activity')
      end

      can :destroy, Activity do |a|
        a.tie.permission?(user, 'destroy', 'activity')
      end
    end
  end
end
