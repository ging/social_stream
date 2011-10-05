ThinkingSphinx::AbstractAdapter.class_eval do
  class << self
    def detect_with_rescue(*args)
      detect_without_rescue(*args)
    rescue
    end

    alias_method_chain :detect, :rescue
  end
end
