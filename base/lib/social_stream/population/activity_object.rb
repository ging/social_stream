module SocialStream
  module Population
    class ActivityObject
      def initialize(klass, &block)
        puts "#{ klass.name } population"
        start_time = Time.now

        10.times do
          author = ::Actor.all.sample
          owner = author
          relation_ids = [Relation::Public.instance.id]

          populate klass, author, owner, relation_ids, &block
        end

        ties = Tie.allowing('create', 'activity').all
        PowerLaw.new ties.sample(ties.count / 3) do |t|

          author = t.receiver
          owner  = t.sender
          relation_ids = Array(t.relation_id)

          populate klass, author, owner, relation_ids, &block
        end

        end_time = Time.now
        puts '   -> ' +  (end_time - start_time).round(4).to_s + 's'
      end

      def populate klass, author, owner, relation_ids, &block
        user_author = ( author.subject_type == "User" ? author : author.user_author )
        timestamps = Timestamps.new

        o = klass.new

        o.created_at = timestamps.created
        o.updated_at = timestamps.updated
        o.author_id  = author.id
        o.owner_id   = owner.id
        o.user_author_id = user_author.id
        o.relation_ids = relation_ids

        yield o

        o.save!

        o.post_activity.update_attributes(:created_at => o.created_at,
                                          :updated_at => o.updated_at)

        o
      end
    end
  end
end
