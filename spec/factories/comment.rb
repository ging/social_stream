Factory.define :comment do |p|
  p.sequence(:text)  { |n| "Comment #{ n }" }
  p._activity_tie_id { |q| q.association(:friend) }
end
