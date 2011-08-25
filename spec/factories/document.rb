Factory.define :document do |d|
  d.file { Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), 'files', 'small.pdf'),
                                       'application/pdf') }

  d._contact_id { Factory(:friend).contact_id }
  d._relation_ids { |q| Array(Contact.find(q._contact_id).sender.relation_customs.sort.first.id) }
end

Factory.define :public_document, :parent => :document do |d|
  d._contact_id { Factory(:self_contact).id }
  d._relation_ids { |q| Array(Contact.find(q._contact_id).sender.relation_public.id) }
end

Factory.define :private_document, :parent => :document do |d|
  d.file { Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), 'files', 'small.pdf'),
                                       'application/pdf') }
  d._contact_id { Factory(:self_contact).id }
  d._relation_ids { |q| Array(Contact.find(q._contact_id).sender.relation_customs.sort.first.id) }
end
