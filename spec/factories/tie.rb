Factory.define :tie do |t|
  t.sender { |s| Factory(:user).actor }
  t.receiver { |r| Factory(:user).actor }
  t.relation { |r| Relation.mode('User', 'User').strongest }
end

# UserToUser ties

Factory.define :friend, :parent => :tie do |t|
  t.relation { |r| Relation.mode('User', 'User').find_by_name('friend') }
end

Factory.define :friend_request, :parent => :tie do |t|
  t.relation { |r| Relation.mode('User', 'User').find_by_name('friend_request') }
end

Factory.define :public, :parent => :tie do |t|
  t.relation { |r| Relation.mode('User', 'User').find_by_name('public') }
end

# UserToGroup ties
Factory.define :u2g_tie, :parent => :tie do |t|
  t.receiver { |r| Factory(:group).actor }
  t.relation { |r| Relation.mode('User', 'Group').strongest }
end

Factory.define :member, :parent => :u2g_tie do |t|
  t.relation { |r| Relation.mode('User', 'Group').find_by_name('member') }
end

Factory.define :follower, :parent => :u2g_tie do |t|
  t.relation { |r| Relation.mode('User', 'Group').find_by_name('follower') }
end

# GroupToUser ties
Factory.define :g2u_tie, :parent => :tie do |t|
  t.sender { |r| Factory(:group).actor }
  t.relation { |r| Relation.mode('Group', 'User').strongest }
end

Factory.define :g2u_member, :parent => :tie do |t|
  t.relation { |r| Relation.mode('Group', 'User').find_by_name('member') }
end
