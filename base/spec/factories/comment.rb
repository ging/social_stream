Factory.define :comment do |p|
  p.sequence(:text)  { |n| "Comment #{ n }" }
  p.author_id { Factory(:friend).receiver.id }
  p.owner_id  { |q| Actor.find(q.author_id).received_ties.first.sender.id }
  p.user_author_id { |q| q.author_id }
end
