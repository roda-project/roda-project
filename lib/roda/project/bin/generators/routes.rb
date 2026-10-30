# frozen_string_literal: true

class Roda
  module Project
    module Bin
      class Generators < ::Thor
        class Routes < Roda::Project::Bin::Generator
          DEFAULT_VIEW_NAME = "index"

          def call
            if branch_name.nil? || branch_name.empty? || routes_list.nil? || routes_list.empty?
              puts "Usage: bin/roda g routes branch_name route1 method:route2"
              exit 1
            end

            puts "* creating routes"
            generate_routes
            generate_nested_branch_files
            generate_views
            generate_tests
            generate_inertia_view_tests
          end

          private

          def generate_routes
            filename = File.join(ensure_and_get_path("app/routes", branch_name), "#{branch_name}.rb")
            write_file(filename, routes_file_content)
          end

          def generate_nested_branch_files
            return unless branch_name.include?("/")

            branch_prefixes.each { |prefix| generate_nested_branch_file(prefix) }
          end

          def generate_nested_branch_file(prefix)
            filename = File.join("app/routes", "#{prefix}.rb")

            if File.exist?(filename)
              ensure_hash_branches_line(filename, prefix)
            else
              FileUtils.mkdir_p(File.dirname(filename))
              write_file(filename, NestedBranchFileBuilder.new(project_name:, prefix:).content)
            end
          end

          def generate_views
            generate_inertia_views if view_mode == :inertia
            generate_erb_views if view_mode == :erb
          end

          def generate_erb_views
            dir = File.join("app/views", branch_name)
            FileUtils.mkdir_p(dir)
            view_routes.each { |route| write_file(File.join(dir, "#{route.name || DEFAULT_VIEW_NAME}.erb"), "") }
          end

          def generate_inertia_views
            write_inertia_files(".jsx", &:component_content)
          end

          def generate_tests
            test_filename = File.join(ensure_and_get_path("spec/app/routes", branch_name), "#{branch_name}_spec.rb")
            write_file(test_filename, RouteSpecBuilder.new(branch_name:, routes:).content)
          end

          def generate_inertia_view_tests
            write_inertia_files(".test.js", &:test_content) if view_mode == :inertia
          end

          def write_inertia_files(extension)
            views_dir = "app/assets/js/inertia/views"
            FileUtils.mkdir_p(views_dir)
            view_routes.each do |route|
              path = InertiaPath.new(branch_name, route.name)
              filename = File.join(views_dir, "#{path.view_path}#{extension}")
              FileUtils.mkdir_p(File.dirname(filename))
              write_file(filename, yield(InertiaViewBuilder.new(path)))
            end
          end

          def routes_file_content
            RoutesFileBuilder.new(project_name:, branch_name:, routes:, view_mode:).content
          end

          def ensure_hash_branches_line(filename, prefix)
            expected_line = Namespace.hash_branches_line(prefix)
            return if File.read(filename).include?(expected_line)

            puts "  warning: #{filename} already exists — please add:"
            puts "    #{expected_line}"
          end

          def branch_prefixes
            parts = branch_name.split("/")
            (0...parts.length - 1).map { |index| parts[0..index].join("/") }
          end

          def view_mode = @view_mode ||= compute_view_mode

          def compute_view_mode
            return :none unless @options[:views]

            views_exist = @context.inertia? ? Dir.exist?("app/assets/js/inertia/views") : Dir.exist?("app/views")
            return :none unless views_exist

            @context.inertia? ? :inertia : :erb
          end

          def routes = @routes ||= routes_list.map { |route_str| Route.parse(route_str) }

          def view_routes = @view_routes ||= routes.select(&:get?)

          def project_name = @context.const_project_name

          def write_file(filename, content)
            File.write(filename, content)
            action_success_message(filename)
          end

          def routes_list = @routes_list ||= @args[1..]

          def branch_name = @branch_name ||= @args[0]
        end
      end
    end
  end
end
