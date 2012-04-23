Factory.define :document do |d|
  d.sequence(:title)  { |n| "Document #{ n }" }
  d.file { Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), 'files', 'small.pdf'),
                                       'application/pdf') }

  d.author_id { Factory(:friend).receiver.id }
  d.owner_id  { |q| Actor.find(q.author_id).received_ties.first.sender.id }
  d.user_author_id { |q| q.author_id }
end

Factory.define :public_document, :parent => :document do |d|
  d.owner_id  { |q| q.author_id }
  d.relation_ids { |q| Array(Relation::Public.instance.id) }
end

Factory.define :private_document, :parent => :document do |d|
  d.file { Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), 'files', 'small.pdf'),
                                       'application/pdf') }
  d.owner_id  { |q| q.author_id }
  d.relation_ids  { |q| Actor.find(q.author_id).relation_customs.sort.first.id }
end
