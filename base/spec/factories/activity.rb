# Helpers for building the post activity
#
class ActivityObjectSpecHelper < ActiveRecord::Base
  set_table_name "activity_objects"
end

class PostSpecHelper < ActiveRecord::Base
  set_table_name "posts"

  belongs_to :activity_object_spec_helper, :foreign_key => "activity_object_id"
end

Factory.define :activity_object_spec_helper do |a|
  a.object_type "Post"
  a.description "Post spec helper"
end

Factory.define :post_spec_helper do |p|
  p.association :activity_object_spec_helper
end

#
## End of helpers

Factory.define :activity do |a|
  a.author        { Factory(:user).actor }
  a.user_author   { |b| b.author }
  a.owner         { |b| Factory(:friend, :contact => Factory(:contact, :receiver => b.author)).sender }
  a.activity_verb { ActivityVerb["post"] }
  a.relation_ids  { |b| [ b.owner.relation_custom('friend').id ] }
  a.activity_object_ids { |b|
    # Create post
    post = Factory(:post,
                   :author_id => b.author_id,
                   :owner_id  => b.owner_id,
                   :user_author => b.user_author_id)

    post.activities.delete_all

    [post.activity_object_id]
  }
end

Factory.define :self_activity, :parent => :activity do |a|
  a.author       { Factory(:user).actor }
  a.user_author  { |b| b.author }
  a.owner        { |b| b.author }
  a.relation_ids { |b| [ b.author.relation_custom('friend').id ] }
  a.activity_object_ids { |b|
    # Create post
    post = Factory(:post,
                   :author_id => b.author_id,
                   :owner_id  => b.owner_id,
                   :user_author => b.user_author_id,
                   :relation_ids => b.relation_ids)

    post.activities.delete_all

    [post.activity_object_id]
  }

end

Factory.define :public_activity, :parent => :activity do |a|
  a.relation_ids  { |b| Array(Relation::Public.instance.id) }
end

Factory.define :like_activity, :class => 'Activity' do |a|
  a.association :parent, :factory => :activity
  a.author        { |b| Factory(:friend, :sender => b.parent.owner).receiver }
  a.user_author   { |b| b.author }
  a.owner         { |b| b.parent.owner }
  a.activity_verb { ActivityVerb["like"] }
  a.relation_ids  { |b| b.parent.relation_ids }
  a.after_build   { |b| b.activity_object_ids = b.parent.activity_object_ids }
end


Factory.define :fan_activity, :parent => :public_activity do |a|
  a.activity_objects { |b| Array(b.receiver.activity_object) }
end
