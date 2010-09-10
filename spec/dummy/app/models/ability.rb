class Ability
  include CanCan::Ability

  def initialize(user)
    can :create, Activity do |a|
      # All ties authors must the user
      a.tie.sender_subject == user &&
        a.tie.permission?(user, 'create', 'resources')
    end

    can :read, Activity do |a|
      a.tie.permission?(user, 'read', 'resources')
    end

    can :update, Activity do |a|
      a.tie.permission?(user, 'update', 'resources')
    end

    can :destroy, Activity do |a|
      a.tie.permission?(user, 'destroy', 'resources')
    end
  end
end
