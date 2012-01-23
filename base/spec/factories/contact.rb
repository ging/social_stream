Factory.define :contact do |c|
  c.sender   { |s| Factory(:user).actor }
  c.receiver { |r| Factory(:user).actor }
  c.user_author { |d| d.sender }
end

Factory.define :self_contact, :parent => :contact do |c|
  c.receiver { |d| d.sender }
end

Factory.define :group_contact, :parent => :contact do |g|
  g.sender { |s| Factory(:group).actor }
  g.after_build { |h| h.user_author = h.sender.user_author }
end

Factory.define :g2g_contact, :parent => :group_contact do |g|
  g.receiver { |r| Factory(:group).actor }
end
