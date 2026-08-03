class Roda
  module Project
    class Generator
      include Helpers::Template
      include Helpers::Ids

      def initialize(context: MainContext.new, args: [], dir: nil)
        @context = context
        @args = args
        @dir = dir
      end

      def call
        false
      end
    end
  end
end
