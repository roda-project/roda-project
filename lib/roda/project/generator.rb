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

      def puts_create_message(path)
        puts(pastel.green("      create  ") + path)
      end
    end
  end
end
