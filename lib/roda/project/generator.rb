class Roda
  module Project
    class Generator
      include Helpers::Template
      include Helpers::Ids

      attr_reader :pastel

      def initialize(context: MainContext.new, args: [], options: {}, dir: nil, pastel: Pastel.new)
        @context = context
        @args = args
        @options = options
        @dir = dir
        @pastel = pastel
      end

      def call
        false
      end

      protected

      def action_success_message(path, action = "create")
        puts(pastel.green("      #{action}  ") + path)
      end
    end
  end
end
