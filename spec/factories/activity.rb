Factory.define :activity do |a|
  a.association :tie
  a.activity_verb { ActivityVerb["post"] }
end

Factory.define :like_activity, :parent => :activity do |a|
  a.association :parent, :factory => :activity
  a.activity_verb { ActivityVerb["like"] }
  a.tie { |tie| tie.association(:tie, :receiver => tie.parent.tie.receiver) }
end
