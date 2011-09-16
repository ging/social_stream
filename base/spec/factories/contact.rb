Factory.define :contact do |c|
  c.sender   { |s| Factory(:user).actor }
  c.receiver { |r| Factory(:user).actor }
end

Factory.define :self_contact, :parent => :contact do |c|
  c.receiver { |d| d.sender }
end

Factory.define :group_contact, :parent => :contact do |g|
  g.sender { |s| Factory(:group).actor }
end

Factory.define :g2g_contact, :parent => :group_contact do |g|
  g.receiver { |r| Factory(:group).actor }
end
