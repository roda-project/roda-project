module Roda
  module Project
    module Rake
      class Generators
        def initialize(context: context, dir:)
          @context = context
          @dir = dir
        end
      end
    end
  end
end
