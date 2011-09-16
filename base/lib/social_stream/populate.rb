module SocialStream
  module Populate

    class << self
      # Yields each element of array y times given by 
      # {power law distribution}[http://en.wikipedia.org/wiki/Power_law]
      # y = ax**k + e
      # 
      # Options: Each constant in the function
      #
      def power_law(array, options = {})
        options[:a] ||= array.size
        options[:k] ||= -2.5
        options[:e] ||= 1

        array.each do |i|
          value = options[:a] * (array.index(i) + 1) ** options[:k] + options[:e]

          value.round.times do
            yield i
          end
        end
      end
    end
  end
end
