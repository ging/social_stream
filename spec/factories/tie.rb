Factory.define :tie do |t|
  t.sender   { |s| Factory(:user).actor }
  t.receiver { |r| Factory(:user).actor }
end

# User ties

Factory.define :friend, :parent => :tie do |t|
  t.after_build { |u| u.relation = u.sender.relation('friend') }
end

Factory.define :acquaintance, :parent => :tie do |t|
  t.after_build { |u| u.relation = u.sender.relation('acquaintance') }
end

Factory.define :public, :parent => :tie do |t|
  t.after_build { |u| u.relation = u.sender.relation_public }
end

# Group ties
Factory.define :g2u_tie, :parent => :tie do |t|
  t.sender   { |u| Factory(:group).actor }
end

Factory.define :member, :parent => :g2u_tie do |t|
  t.after_build { |u| u.relation = u.sender.relation('member') }
end

Factory.define :g2g_tie, :parent => :tie do |t|
  t.sender   { |u| Factory(:group).actor }
  t.receiver { |u| Factory(:group).actor }
end

Factory.define :partner, :parent => :g2g_tie do |t|
  t.after_build { |u| u.relation = u.sender.relation('partner') }
end

