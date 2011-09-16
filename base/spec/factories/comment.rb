Factory.define :comment do |p|
  p.sequence(:text)  { |n| "Comment #{ n }" }
  p._contact_id { Factory(:friend).contact_id }
  p._relation_ids { |q| Array(Contact.find(q._contact_id).sender.relation_customs.sort.first.id) }
end
