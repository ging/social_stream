Factory.define :picture do |p|
  p.file { Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), 'files', 'rails.png'),
                                       'image/png') }

  p._contact_id { Factory(:friend).contact_id }
  p._relation_ids { |q| Array(Contact.find(q._contact_id).sender.relation_customs.sort.first.id) }
end

Factory.define :public_picture, :parent => :picture do |p|
  p._contact_id { Factory(:self_contact).id }
  p._relation_ids { |q| Array(Contact.find(q._contact_id).sender.relation_public.id) }
end

Factory.define :private_picture, :parent => :picture do |p|
  p.file { Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), 'files', 'privado.png'),
                                       'image/png') }
  p._contact_id { Factory(:self_contact).id }
  p._relation_ids { |q| Array(Contact.find(q._contact_id).sender.relation_customs.sort.first.id) }
end

