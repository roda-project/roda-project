# frozen_string_literal: true

class Roda
  module Project
    module Bin
      class Generators
        class Routes
          class RoutesFileBuilder
            def initialize(project_name:, branch_name:, routes:, view_mode:)
              @project_name = project_name
              @branch_name = branch_name
              @routes = routes
              @view_mode = view_mode
            end

            def content
              <<~RUBY
                class #{@project_name}
                  #{branch_header}
                #{route_definitions}
                  end
                end
              RUBY
            end

            private

            def route_definitions
              @routes.map { |route| build_route_definition(route) }.join("\n\n")
            end

            def build_route_definition(route)
              view_line = build_view_line(route)
              route_block(route, view_line)
            end

            def build_view_line(route)
              return "" unless route.get? && @view_mode != :none

              if @view_mode == :inertia
                "\n      inertia('#{InertiaPath.new(@branch_name, route.name).view_path}')"
              else
                "\n      view('#{route.name || DEFAULT_VIEW_NAME}')"
              end
            end

            def route_block(route, view_line)
              route_name = route.name ? " \"#{route.name}\"" : ""
              "    r.#{route.method}#{route_name} do#{view_line}\n    end"
            end

            def branch_header
              return "hash_branch \"#{@branch_name}\" do |r|" unless @branch_name.include?("/")

              parts = @branch_name.split("/")
              sub_path = parts[0..-2].join("/")
              "hash_branch #{Namespace.for_path(sub_path)}, \"#{parts.last}\" do |r|"
            end
          end
        end
      end
    end
  end
end
