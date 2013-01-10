if Rails.env == 'development'
  require 'thinking-sphinx'

  ThinkingSphinx.define_indexes = false
end
