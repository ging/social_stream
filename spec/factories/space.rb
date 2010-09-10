Factory.define :space do |s|
  s.sequence(:name) { |n| "Space #{ n }" }
end
