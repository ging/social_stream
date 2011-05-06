Factory.define :sphere do |s|
  s.sequence(:name) { |n| "Sphere #{ n }" }
  s.association :actor
end

