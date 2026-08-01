module Roda
  module Project
    class Generator
      include Helpers::Template
      include Helpers::Ids

      def initialize(context: Context.new, dir: nil)
        @context = context
        @dir = dir
      end

      def call
        false
      end
    end
  end
end
