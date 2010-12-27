Factory.define :post do |p|
  p.sequence(:text)  { |n| "Post #{ n }" }
  p._activity_tie_id { |q| q.association(:friend) }
end
