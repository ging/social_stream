module SocialStream
  class Ability
    module Base
      include CanCan::Ability

      # Create a new ability for this user, who is currently representing subject
      def initialize(subject)
        
        #Download alias action
        alias_action :download, :to => :show
        
        # Activity Objects
        (SocialStream.objects - [ :actor, :comment ]).map{ |obj|
          obj.to_s.classify.constantize
        }.each do |klass|
          can :create, klass do |object| # can :create, Post do |post|
            object.author.present? &&
              object.owner.present? &&
              object.author == Actor.normalize(subject) &&
              ( object.author == object.owner ||
                object.owner.allow?(subject, 'create', 'activity') )
          end

          can :read, klass do |object| # can :read, Post do |post|
            object.authored_or_owned_by?(subject) ||
              object.relation_ids.include?(Relation::Public.instance.id) ||
              subject.present? && (object.relation_ids & subject.received_relation_ids).any?
          end

          can :update, klass do |object| # can :update, Post do |post|
            object.authored_or_owned_by?(subject)
          end

          can :destroy, klass do |object| # can :destroy, Post do |post|
            object.authored_or_owned_by?(subject)
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
          a.public? ||
            subject.present? &&
            a.audience.include?(subject.actor) 
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
            g.author_id == Actor.normalize_id(subject)
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
end
