# When a new {SocialStream::Models::Subject subject} is created, a initial set
# of relations is created for him. Afterwards, the {SocialStream::Models::Subject subject}
# can customize them and adapt them to his own preferences.
#
# Default relations are defined at config/relations.yml
#
class Relation::Custom < Relation
  # Default relations are defined in this configuration file
  CONFIG = File.join(::Rails.root, 'config', 'relations.yml')

  # This is weird. We must call #inspect before has_ancestry for Relation::Custom
  # to recognize STI
  inspect
  has_ancestry

  belongs_to :actor

  validates_presence_of :name, :actor_id
  validates_uniqueness_of :name, :scope => :actor_id

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
        rels[name] =
          create! :actor =>         actor,
                  :name  =>         cfg_rel['name'],
                  :receiver_type => cfg_rel['receiver_type']

        if (ps = cfg_rel['permissions']).present?
          ps.each do |p| 
            p.push(nil) if p.size == 1

            rels[name].permissions << 
              Permission.find_or_create_by_action_and_object(*p)
          end 
        end
      end

      # Parent, relations must be set after creation
      # FIXME: Can fix with ruby 1.9 and ordered hashes
      cfg_rels.each_pair do |name, cfg_rel|
        rels[name].update_attribute(:parent, rels[cfg_rel['parent']])
      end

      rels.values
    end

    # A relation in the top of a strength hierarchy
    def strongest
      roots
    end
  end

  # Compare two relations
  def <=> rel
    return -1 if rel.is_a?(Public)

    if ancestor_ids.include?(rel.id)
      1
    elsif rel.ancestor_ids.include?(id)
      -1
    else
      0
    end
  end

  # Other relations below in the same hierarchy that this relation
  def weaker
    descendants
  end

  # Relations below or at the same level of this relation
  def weaker_or_equal
    subtree
  end

  # Other relations above in the same hierarchy that this relation
  def stronger
    ancestors
  end

  # Relations above or at the same level of this relation
  def stronger_or_equal
    path
  end
end
