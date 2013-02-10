module Rack
  class Padlock
    class StringUtil
      def elide(string, max)
        length = string.length
        return string unless length > max
        return string if max <= 0
        amount_to_preserve_on_the_left = (max/2.0).ceil
        amount_to_preserve_on_the_right = max - amount_to_preserve_on_the_left
        left = string[0..(amount_to_preserve_on_the_left-1)]
        right = string[-amount_to_preserve_on_the_right..-1]
        "#{left}...#{right}"
      end
    end
  end
end