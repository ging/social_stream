Factory.define :actor do |s|
  s.sequence(:name) { |n| "Actor #{ n }" }
  s.subject_type "User"
end

