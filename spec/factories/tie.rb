Factory.define :tie do |t|
  t.sender { |s| Factory(:user).actor }
  t.receiver { |r| Factory(:user).actor }
  t.relation { |r| Relation.where(:mode => 'User-User').strongest }
end

# UserToUser ties

Factory.define :friend_tie, :parent => :tie do |t|
  t.relation { |r| Relation['User-User', 'Friend'] }
end

Factory.define :fof_tie, :parent => :tie do |t|
  t.relation { |r| Relation['User-User' ,'FriendOfFriend'] }
end

Factory.define :public_tie, :parent => :tie do |t|
  t.relation { |r| Relation['User-User', 'Public'] }
end

# UserToSpace ties
Factory.define :u2s_tie, :parent => :tie do |t|
  t.receiver { |r| Factory(:space).actor }
  t.relation { |r| Relation.where(:mode => 'User-Space').strongest }
end

Factory.define :admin_tie, :parent => :u2s_tie do |t|
  t.relation { |r| Relation['User-Space', 'Admin'] }
end

Factory.define :user_tie, :parent => :u2s_tie do |t|
  t.relation { |r| Relation['User-Space', 'User'] }
end

Factory.define :follower_tie, :parent => :u2s_tie do |t|
  t.relation { |r| Relation['User-Space', 'Follower'] }
end

