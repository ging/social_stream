Factory.define :picture do |p|
  p.sequence(:title)  { |n| "Picture #{ n }" }
  p.file { Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), 'files', 'rails.png'),
                                       'image/png') }

  p.author_id { Factory(:friend).receiver.id }
  p.owner_id  { |q| Actor.find(q.author_id).received_ties.first.sender.id }
  p.user_author_id { |q| q.author_id }
end

Factory.define :public_picture, :parent => :picture do |p|
  p.owner_id  { |q| q.author_id }
  p.relation_ids { |q| Array(Relation::Public.instance.id) }
end

Factory.define :private_picture, :parent => :picture do |p|
  p.file { Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), 'files', 'privado.png'),
                                       'image/png') }
  p.owner_id  { |q| q.author_id }
  p.relation_ids  { |q| Actor.find(q.author_id).relation_customs.sort.first.id }
end

