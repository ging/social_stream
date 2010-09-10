Factory.define :activity do |a|
  a.association :tie
  a.activity_verb { ActivityVerb[ActivityVerb::Available.first] }
end
