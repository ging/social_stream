Factory.define :group do |g|
  g.sequence(:name) { |n| "Group #{ n }" }
  g._contact_id { |g| Factory(:user).ego_contact.id }
end
