Factory.define :group do |g|
  g.sequence(:name) { |n| "Group #{ n }" }
  g._founder { |g| Factory(:user).slug }
end
