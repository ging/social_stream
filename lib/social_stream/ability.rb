module SocialStream
  class Ability
    include CanCan::Ability

    # Create a new ability for this user, who is currently representing subject
    def initialize(subject)

      # Activity Objects
      (SocialStream.objects - [ :actor ]).map{ |obj|
        obj.to_s.classify.constantize
      }.each do |klass|
        can :create, klass do |k| # can :create, Post do |post|
          k._activity_tie.sender_id == subject.actor_id &&
            k._activity_tie.receiver.allow?(subject, 'create', 'activity')
        end

        can :read, klass do |k| # can :read, Post do |post|
          k.post_activity.tie.allow?(subject, 'read', 'activity')
        end

        can :update, klass do |k| # can :update, Post do |post|
          k.post_activity.tie.allow?(subject, 'update', 'activity')
        end

        can :destroy, klass do |k| # can :destroy, Post do |post|
          k.post_activity.tie.sender_id == Actor.normalize_id(subject) ||
            k.post_activity.tie.allow?(subject, 'destroy', 'activity')
        end
      end

      # Activities
      can :create, Activity do |a|
        a.tie.allow?(subject, 'create', 'activity')
      end

      can :read, Activity do |a|
        a.tie.allow?(subject, 'read', 'activity')
      end

      can :update, Activity do |a|
        a.tie.allow?(subject, 'update', 'activity')
      end

      can :destroy, Activity do |a|
        a.tie.allow?(subject, 'destroy', 'activity')
      end

      # Users
      can :read, User

      can :update, User do |u|
        u.represented_by?(subject)
      end

      # Groups
      can :read, Group

      can :create, Group do |g|
        subject.present? &&
          g._founder == subject.slug
      end

      can :update, Group do |g|
        g.represented_by?(subject)
      end

      can :destroy, Group do |g|
        g.represented_by?(subject)
      end

      can :read, Profile

      # Profile
      can :update, Profile do |p|
        p.subject.represented_by?(subject)
      end
    end
  end
end
