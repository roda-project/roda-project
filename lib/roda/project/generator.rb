class Roda
  module Project
    class Generator
      include Helpers::Template
      include Helpers::Ids

      def initialize(context: MainContext.new, args: [], options: {}, dir: nil)
        @context = context
        @args = args
        @options = options
        @dir = dir
      end

      def call
        false
      end
    end
  end
end
