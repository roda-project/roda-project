# frozen_string_literal: true

class Roda
  module Project
    module Bin
      class Generators
        class Routes
          class NestedBranchFileBuilder
            def initialize(project_name:, prefix:)
              @project_name = project_name
              @prefix = prefix
            end

            def content
              <<~RUBY
                class #{@project_name}
                  #{header} # #{@prefix} branch
                    r.hash_branches(#{Namespace.for_path(@prefix)}) # #{@prefix}/ +1 routes
                  end
                end
              RUBY
            end

            private

            def header
              return "hash_branch \"#{@prefix}\" do |r|" unless @prefix.include?("/")

              parts = @prefix.split("/")
              parent_path = parts[0..-2].join("/")
              "hash_branch #{Namespace.for_path(parent_path)}, \"#{parts.last}\" do |r|"
            end
          end
        end
      end
    end
  end
end
