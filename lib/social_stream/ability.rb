module SocialStream
  class Ability
    include CanCan::Ability

    def initialize(user)

      # Activity Objects
      (SocialStream.objects - [ :actor ]).map{ |obj|
        obj.to_s.classify.constantize
      }.each do |klass|
        can :create, klass do |k| # can :create, Post do |post|
          k._activity_tie.sender.represented_by?(user) &&
            ( k._activity_tie.reflexive? ||
              # FIXME: representations
              k._activity_tie.receiver.allow?(user, 'create', 'activity') )
        end

        can :read, klass do |k| # can :read, Post do |post|
          k.post_activity.tie.allow?(user, 'read', 'activity')
        end

        can :update, klass do |k| # can :update, Post do |post|
          k.post_activity.tie.allow?(user, 'update', 'activity')
        end

        can :destroy, klass do |k| # can :destroy, Post do |post|
          k.post_activity.tie.sender.represented_by?(user) ||
            k.post_activity.tie.allow?(user, 'destroy', 'activity')
        end
      end

      # Activities
      can :create, Activity do |a|
        a.tie.allow?(user, 'create', 'activity')
      end

      can :read, Activity do |a|
        a.tie.allow?(user, 'read', 'activity')
      end

      can :update, Activity do |a|
        a.tie.allow?(user, 'update', 'activity')
      end

      can :destroy, Activity do |a|
        a.tie.allow?(user, 'destroy', 'activity')
      end

      # Groups
      can :read, Group

      can :create, Group do |g|
        user.present? &&
          ( g._founder == user.slug ||
            Actor.find_by_slug!(g._founder).represented_by?(user) )
      end

      can :update, Group do |g|
        g.represented_by?(user)
      end

      can :destroy, Group do |g|
        g.represented_by?(user)
      end

      can :read, Profile

      # Profile
      can :update, Profile do |p|
        p.subject.represented_by?(user)
      end

      # Representation
      can :create, Representation do |r|
        r.subject.represented_by?(user)
      end
    end
  end
end
