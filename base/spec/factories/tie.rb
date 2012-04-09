Factory.define :tie do |t|
  t.association :contact
end

# User ties

Factory.define :friend, :parent => :tie do |t|
  t.after_build { |u| u.relation = u.sender.relation_custom('friend') }
end

Factory.define :acquaintance, :parent => :tie do |t|
  t.after_build { |u| u.relation = u.sender.relation_custom('acquaintance') }
end

Factory.define :public, :parent => :tie do |t|
  t.after_build { |u| u.relation = Relation::Public.instance }
end

Factory.define :reject, :parent => :tie do |t|
  t.after_build { |u| u.relation = Relation::Reject.instance }
end

Factory.define :follow, :parent => :tie do |t|
  t.after_build { |u| u.relation = Relation::Follow.instance }
end

# Group ties
Factory.define :g2u_tie, :parent => :tie do |t|
  t.contact { |c| Factory(:group_contact) }
end

Factory.define :member, :parent => :g2u_tie do |t|
  t.after_build { |u| u.relation = u.sender.relation_custom('member') }
end

Factory.define :g2g_tie, :parent => :tie do |t|
  t.contact { |c| Factory(:g2g_contact) }
end

Factory.define :partner, :parent => :g2g_tie do |t|
  t.after_build { |u| u.relation = u.sender.relation_custom('partner') }
end

Factory.define :group_public, :parent => :g2g_tie do |t|
  t.after_build { |u| u.relation = Relation::Public.instance }
end

