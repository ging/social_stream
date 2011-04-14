class Relation
  # When a new {SocialStream::Models::Subject subject} is created, a initial set
  # of relations is created for him. Afterwards, the {SocialStream::Models::Subject subject}
  # can customize them and adapt them to his own preferences.
  #
  # Default relations are defined at config/relations.yml
  #
  class Custom < Relation
    # Default relations are defined in this configuration file
    CONFIG = File.join(::Rails.root, 'config', 'relations.yml')

    acts_as_nested_set

    belongs_to :sphere
    has_one    :actor, :through => :sphere

    validates_presence_of :name, :sphere_id

    after_create :initialize_tie

    class << self
      # Relations configuration
      def config
        @config ||= YAML.load_file(CONFIG)
      end

      def defaults_for(actor)
        cfg_rels = config[actor.subject_type.underscore]

        if cfg_rels.nil?
          raise "Undefined relations for subject type #{ actor.subject_type }. Please, add an entry to #{ CONFIG }"
        end

        rels = {}

        cfg_rels.each_pair do |name, cfg_rel|
          raise("Must associatiate relation #{ cfg_rel['name'] } to a sphere") if cfg_rel['sphere'].blank?
          sphere = actor.spheres.find_or_create_by_name(cfg_rel['sphere'])

          rels[name] =
            Relation::Custom.create! :sphere        => sphere,
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

    private

    # Create reflexive tie for the owner of this {Relation::Custom custom relation}
    def initialize_tie
      ties.create! :sender => sphere.actor,
                   :receiver => sphere.actor
    end
  end
end
