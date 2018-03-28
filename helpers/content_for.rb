module FunkyWorldCup
  module Helpers
    module ContentFor
      def yield_content(symbol)
        content[symbol].map(&:call)
      end

      def content_for(symbol, &block)
        content[symbol] << block
      end

      private

      def content
        @content ||= Hash.new { |h, k| h[k] = [] }
      end
    end
  end
end
