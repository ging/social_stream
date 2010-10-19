module SocialStream
  # Seed you database with initial data for SocialStream
  #
  class Seed
    def initialize(config)
      s = YAML.load_file(config)

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
        relations[name].update_attribute(:default, r['default'])

        # FIXME: optimize
        relations[name].relation_permissions.destroy_all

        if (ps = r['permissions']).present?
          ps.each do |p| 
            relations[name].permissions << 
              Permission.find_or_create_by_action_and_object_and_parameter(*p)
          end 
        end
      end

      # Parent, inverse and granted relations must be set after creation
      rs.each_pair do |name, r|
        %w( parent inverse granted ).each do |s|
          relations[name].__send__("#{ s }=", relations[r[s]]) # relations[name].parent = relations[r['parent']]
        end
        relations[name].save!
      end
    end
  end
end
