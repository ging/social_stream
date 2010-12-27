module SocialStream
  # Seed you database with initial data for SocialStream
  #
  module Relations
    CONFIG = File.join(::Rails.root, 'config', 'relations.yml')

    class << self
      # Relations configuration
      def config
        @config ||= YAML.load_file(CONFIG)
      end

      def create(model)
        cfg_rels = config[model.singularize.underscore]

        if cfg_rels.nil?
          raise "Undefined relations for actor #{ model }. Please, add an entry to #{ CONFIG }"
        end

        rels = {}

        cfg_rels.each_pair do |name, cfg_rel|
          rels[name] =
            Relation.create! :sender_type =>   model,
                             :receiver_type => cfg_rel['receiver_type'],
                             :name =>          cfg_rel['name']

          if (ps = cfg_rel['permissions']).present?
            ps.each do |p| 
              rels[name].permissions << 
                Permission.find_or_create_by_action_and_object_and_function(*p)
            end 
          end
        end

        # Parent, relations must be set after creation
        # FIXME: Can fix with ruby 1.9 and ordered hashes
        cfg_rels.each_pair do |name, cfg_rel|
          rels[name].update_attribute(:parent, rels[cfg_rel['parent']]) if cfg_rel['parent'].present?
        end

        rels.values
      end
    end
  end
end
