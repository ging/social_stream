require 'action_controller/subactivity'

module SocialStream
  mattr_accessor :actors
  @@actors = []

  mattr_accessor :activity_objects
  @@activity_objects = []

  class << self
    def setup
      yield self
    end

    def seed!
      s = YAML.load_file("#{ Rails.root }/db/seeds/social_stream.yml")

      seed_activity_verbs
      seed_relations(s['relations'])
    end

    def seed_activity_verbs
      ActivityVerb::Available.each do |value|
          ActivityVerb.find_or_create_by_name value
      end
    end

    def seed_relations(rs)
      relations = {}

      rs.each_pair do |name, r|
        relations[name] =
          Relation.
          find_or_create_by_sender_type_and_receiver_type_and_name(r['sender_type'],
                                                                   r['receiver_type'],
                                                                   r['name'])
        # FIXME: optimize
        relations[name].relation_permissions.destroy_all

        if (ps = r['permissions']).present?
          ps.each do |p| 
            relations[name].permissions << 
              Permission.find_or_create_by_action_and_object_and_parameter(*p)
          end 
        end
      end

      # Parent and inverse relations must be set after creation
      rs.each_pair do |name, r|
        relations[name].parent  = relations[r['parent']]
        relations[name].inverse = relations[r['inverse']]
        relations[name].save!
      end
    end

  end
end
