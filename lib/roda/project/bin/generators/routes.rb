# rubocop:disable Layout/HeredocIndentation
class Roda
  module Project
    module Bin
      class Generators < ::Thor
        class Routes < Roda::Project::Bin::Generator
          DEFAULT_VIEW_NAME = "index"
          VALID_METHODS = %w[get post delete put patch].freeze

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
          end

          private

          def generate_routes
            filename = File.join(ensure_and_get_path("app/routes", branch_name), "#{branch_name}.rb")
            route_definitions = routes_list.map { |route_str| build_route_definition(route_str) }.join("\n\n")

            write_file(filename, routes_file_content(route_definitions))
          end

          def generate_views
            return unless must_generate_views?

            @context.inertia? ? generate_inertia_views : generate_erb_views
          end

          def generate_erb_views
            branch_views_dir = File.join("app/views", branch_name)
            FileUtils.mkdir_p(branch_views_dir)
            routes_list.each do |route_str|
              method, name = parse_route_string(route_str)
              next unless method == "get"

              name = DEFAULT_VIEW_NAME if name.nil?
              write_file(File.join(branch_views_dir, "#{name}.erb"), "")
            end
          end

          def generate_inertia_views
            views_dir = "app/assets/js/inertia/views"
            FileUtils.mkdir_p(views_dir)
            routes_list.each do |route_str|
              method, name = parse_route_string(route_str)
              next unless method == "get"

              path = InertiaPath.new(branch_name, name)
              view_filename = File.join(views_dir, "#{path.view_path}.jsx")
              FileUtils.mkdir_p(File.dirname(view_filename))
              write_file(view_filename, inertia_component_content(path))
            end
          end

          def generate_tests
            test_filename = File.join(ensure_and_get_path("spec/app/routes", branch_name), "#{branch_name}_spec.rb")
            nesting_level = branch_name.count("/")
            relative_spec_helper_path = "../" * (2 + nesting_level) + "spec_helper"

            test_route_definitions = routes_list.map { |route_str| build_test_definition(route_str) }.join("\n")

            test_content = <<~RUBY
              require_relative "#{relative_spec_helper_path}"

              describe "Routes for #{branch_name}" do
              #{test_route_definitions}
              end
            RUBY
            write_file(test_filename, test_content)
          end

          def generate_nested_branch_files
            return unless branch_name.include?("/")

            parts = branch_name.split("/")
            parts[0..-2].each_with_index do |_segment, index|
              prefix = parts[0..index].join("/")
              filename = File.join("app/routes", "#{prefix}.rb")

              if File.exist?(filename)
                ensure_hash_branches_line(filename, namespace_for(prefix))
                next
              end

              dir = File.dirname(filename)
              FileUtils.mkdir_p(dir) unless File.directory?(dir)
              write_file(filename, nested_branch_file_content(prefix, index))
            end
          end

          def build_route_definition(route_str)
            method, name = parse_route_string(route_str)
            view_line = build_view_line(method, name)
            route_block(method, name, view_line)
          end

          def build_view_line(method, name)
            return "" unless method == "get" && must_generate_views?

            if @context.inertia?
              "\n      inertia('#{InertiaPath.new(branch_name, name).view_path}')"
            else
              "\n      view('#{name || DEFAULT_VIEW_NAME}')"
            end
          end

          def route_block(method, name, view_line)
            route_name = name ? " \"#{name}\"" : ""
            "    r.#{method}#{route_name} do#{view_line}\n    end"
          end

          def build_test_definition(route_str)
            method, name = parse_route_string(route_str)
            test_name = name ? " /#{branch_name}/#{name}" : " /#{branch_name}"
            test_path = name ? " \"/#{branch_name}/#{name}\"" : " \"/#{branch_name}\""

            "  it \"responds to #{method.upcase}#{test_name}\" do\n" \
              "    #{method}#{test_path}\n" \
              "    expect(last_response.status).to eq(200)\n" \
              "  end"
          end

          def routes_file_content(route_definitions)
            <<~RUBY
      class #{@context.const_project_name}
        #{build_hash_branch_header}
      #{route_definitions}
        end
      end
            RUBY
          end

          def build_hash_branch_header
            return "hash_branch \"#{branch_name}\" do |r|" unless branch_name.include?("/")

            parts = branch_name.split("/")
            sub_path = parts[0..-2].join("/")
            branch_segment = parts.last
            "hash_branch #{namespace_for(sub_path)}, \"#{branch_segment}\" do |r|"
          end

          def nested_branch_file_content(prefix, index)
            parts = prefix.split("/")
            segment = parts.last
            header = if index.zero?
              "hash_branch \"#{segment}\" do |r|"
            else
              parent_path = parts[0..-2].join("/")
              "hash_branch #{namespace_for(parent_path)}, \"#{segment}\" do |r|"
            end

            <<~RUBY
      class #{@context.const_project_name}
        #{header} # #{prefix} branch
          r.hash_branches(#{namespace_for(prefix)}) # #{prefix}/ +1 routes
        end
      end
            RUBY
          end

          def ensure_hash_branches_line(filename, namespace)
            expected_line = "r.hash_branches(#{namespace})"
            return if File.read(filename).include?(expected_line)

            puts "  warning: #{filename} already exists — please add:"
            puts "    #{expected_line}"
          end

          def namespace_for(sub_path)
            sub_path.include?("/") ? ":\"#{sub_path}\"" : ":#{sub_path}"
          end

          def must_generate_views?
            return false unless @options[:views]

            if @context.inertia?
              Dir.exist?("app/assets/js/inertia/views")
            else
              Dir.exist?("app/views")
            end
          end

          def inertia_component_content(path)
            <<~JSX
              import React from 'react'
              import { Link } from '@inertiajs/react'
              import Layout from '../components/Layout'

              const #{path.component_name} = props => {
                return (<Layout>
                  <div>
                    #{path.display_path}
                  </div>
                </Layout>)
              }

              export default #{path.component_name}
            JSX
          end

          def parse_route_string(route_str)
            method, name = route_str.split(":", 2)
            if name && VALID_METHODS.include?(method)
              [method, name]
            elsif name.nil? && VALID_METHODS.include?(route_str)
              [route_str, nil]
            else
              ["get", route_str]
            end
          end

          def write_file(filename, content)
            File.write(filename, content)
            action_success_message(filename)
          end

          def routes_list
            @routes_list ||= @args[1..]
          end

          def branch_name
            @branch_name ||= @args[0]
          end

          class InertiaPath
            attr_reader :view_path, :component_name, :display_path

            def initialize(branch_name, name)
              @view_path = build_view_path(branch_name, name)
              @component_name = build_component_name(name)
              @display_path = build_display_path(branch_name, name)
            end

            private

            def build_view_path(branch_name, name)
              segments = branch_name.split("/")
              segments << (name || "index")
              (segments[0..-2] + [segments.last.capitalize]).join("/")
            end

            def build_component_name(name)
              (name || "index").capitalize
            end

            def build_display_path(branch_name, name)
              segments = branch_name.split("/")
              segments << (name || "index")
              segments.join("/")
            end
          end
        end
      end
    end
  end
end
# rubocop:enable Layout/HeredocIndentation
