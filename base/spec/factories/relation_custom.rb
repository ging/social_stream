Factory.define(:relation_custom, :class => Relation::Custom) do |c|
  c.sequence(:name) { |n| "Relation custom #{ n }" }
  c.actor { Factory(:user).actor }
end
