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
  a.channel { Factory(:friend).contact.channel }
  a.activity_verb { ActivityVerb["post"] }
  a.relation_ids  { |b| Array(b.sender.relation_custom('friend').id) }
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
  a.channel { Factory(:self_contact).channel }
  a.relation_ids  { |b| Array(b.sender.relation_custom('friend').id) }
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
  a.channel { |b| Factory(:friend, :sender => b.parent.sender).receiver.contact_to!(b.parent.sender).channel }
  a.activity_verb { ActivityVerb["like"] }
  a.relation_ids  { |b| b.parent.relation_ids }
  a.after_build{ |b| b.activity_object_ids = b.parent.activity_object_ids }
end


Factory.define :fan_activity, :parent => :public_activity do |a|
  a.activity_objects { |b| Array(b.receiver.activity_object) }
end
