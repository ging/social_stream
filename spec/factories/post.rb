Factory.define :post do |p|
  p._activity_tie_id { |q| q.association(:tie) }
end
