# This relation model implements Twitter-like relations:
# Users just have followers and followings.
#
# Use this model setting <tt>config.relation_model = :follow</tt> in your
# <tt>config/initializers/social_stream.rb</tt>
class Relation::Follow < Relation::Single
  class << self
    def instance
      first ||
        create(:permissions => Array(Permission.find_or_create_by_action('follow')))
    end
  end
end

