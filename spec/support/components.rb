{
  :base => [ :cancan, :devise, :mock, 'thinking-sphinx' ]
}.each_pair do |component, files|
  files.each do |file|
    require File.expand_path("../../../#{ component }/spec/support/#{ file }.rb", __FILE__)
  end
end
