class Relation::Public < Relation::Single
  # A {Relation::Public public relation} is always the weakest
  def <=>(relation)
    1
  end

  # Are we supporting custom permissions for {Relation::Public}? Not by the moment.
  def allow?(user, action, object)
    action == 'read' && object == 'activity'
  end
end
