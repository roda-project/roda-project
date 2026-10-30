# frozen_string_literal: true

class Roda
  module Project
    module Bin
      class Generators
        class Routes
          class InertiaPath
            attr_reader :view_path, :component_name, :display_path, :layout_import_path

            def initialize(branch_name, name)
              @view_path = build_view_path(branch_name, name)
              @component_name = build_component_name(name)
              @display_path = build_display_path(branch_name, name)
              @layout_import_path = build_layout_import_path
            end

            private

            def build_layout_import_path
              prefix = "../" * (view_path.count("/") + 1)
              "#{prefix}components/Layout"
            end

            def build_view_path(branch_name, name)
              segments = branch_name.split("/")
              segments << (name || DEFAULT_VIEW_NAME)
              (segments[0..-2] + [segments.last.capitalize]).join("/")
            end

            def build_component_name(name)
              (name || DEFAULT_VIEW_NAME).capitalize
            end

            def build_display_path(branch_name, name)
              segments = branch_name.split("/")
              segments << (name || DEFAULT_VIEW_NAME)
              segments.join("/")
            end
          end
        end
      end
    end
  end
end
