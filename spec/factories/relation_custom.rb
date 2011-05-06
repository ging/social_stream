Factory.define(:relation_custom, :class => Relation::Custom) do |c|
  c.sequence(:name) { |n| "Relation custom #{ n }" }
  c.association :sphere
end
