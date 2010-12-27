Factory.define :activity do |a|
  a.association :_tie, :factory => :friend
  a.activity_verb { ActivityVerb["post"] }
end

Factory.define :like_activity, :parent => :activity do |a|
  a.association :parent, :factory => :activity
  a.activity_verb { ActivityVerb["like"] }
  a._tie { |tie| tie.association(:friend, :sender => tie.parent.tie.sender) }
end
