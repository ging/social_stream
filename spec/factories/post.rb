Factory.define :post do |p|
  p.sequence(:text)  { |n| "Post #{ n }" }
  p._contact_id { Factory(:friend).contact_id }
  p._relation_ids { |q| Array(Contact.find(q._contact_id).sender.relation_customs.sort.first.id) }
end

Factory.define :public_post, :parent => :post do |p|
  p._contact_id { Factory(:self_contact).id }
  p._relation_ids { |q| Array(Contact.find(q._contact_id).sender.relation_public.id) }
end
