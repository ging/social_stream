module SocialStream
  class Ability
    include CanCan::Ability

    # Create a new ability for this user, who is currently representing subject
    def initialize(subject)
      
      #Download alias action
      alias_action :download, :to => :show
      
      # Activity Objects
      (SocialStream.objects - [ :actor, :comment ]).map{ |obj|
        obj.to_s.classify.constantize
      }.each do |klass|
        can :create, klass do |k| # can :create, Post do |post|
          k.build_post_activity.allow?(subject, 'create')
        end

        can :read, klass do |k| # can :read, Post do |post|
          k.post_activity.allow?(subject, 'read')
        end

        can :update, klass do |k| # can :update, Post do |post|
          k.post_activity.allow?(subject, 'update')
        end

        can :destroy, klass do |k| # can :destroy, Post do |post|
          k.post_activity.allow?(subject, 'destroy')
        end
      end

      can :create, Comment do |c|
        c._activity_parent.allow?(subject, 'read')
      end

      can :read, Comment do |c|
        c.post_activity.allow?(subject, 'read')
      end

      can :update, Comment do |c|
        c.post_activity.allow?(subject, 'update')
      end

      can :destroy, Comment do |c|
        c.post_activity.allow?(subject, 'destroy')
      end

      # Activities
      can :create, Activity do |a|
        a.allow?(subject, 'create')
      end

      can :read, Activity do |a|
        a.allow?(subject, 'read')
      end

      can :update, Activity do |a|
        a.allow?(subject, 'update')
      end

      can :destroy, Activity do |a|
        a.allow?(subject, 'destroy')
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
          g._contact.sender_id == Actor.normalize_id(subject)
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

      # Privacy
      can [:create, :read, :update, :destroy], Relation::Custom, :actor_id => subject.try(:actor_id)
    end
  end
end
