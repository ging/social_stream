Factory.define :activity do |a|
  a.contact { Factory(:friend).contact }
  a.activity_verb { ActivityVerb["post"] }
  a.relation_ids  { |b| Array(b.sender.relation_custom('friend').id) }
end

Factory.define :self_activity, :parent => :activity do |a|
  a.contact { Factory(:self_contact) }
  a.relation_ids  { |b| Array(b.sender.relation_custom('friend').id) }
end

Factory.define :public_activity, :parent => :activity do |a|
  a.relation_ids  { |b| Array(b.sender.relation_public.id) }
end

Factory.define :like_activity, :parent => :activity do |a|
  a.association :parent, :factory => :activity
  a.contact { |b| Factory(:friend, :sender => b.parent.sender).receiver.contact_to!(b.parent.sender) }
  a.activity_verb { ActivityVerb["like"] }
  a.relation_ids { |b| Array(b.parent.contact.ties.first.relation.id) }
end
