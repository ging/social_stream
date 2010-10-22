Factory.define :actor do |s|
  s.sequence(:name) { |n| "Actor #{ n }" }
end
