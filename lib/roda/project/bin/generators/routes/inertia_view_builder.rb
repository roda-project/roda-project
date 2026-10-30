# frozen_string_literal: true

class Roda
  module Project
    module Bin
      class Generators
        class Routes
          class InertiaViewBuilder
            def initialize(path)
              @path = path
            end

            def component_content
              <<~JSX
                import React from 'react'
                import { Link } from '@inertiajs/react'
                import Layout from '#{@path.layout_import_path}'

                const #{@path.component_name} = props => {
                  return (<Layout>
                    <div>
                      #{@path.display_path}
                    </div>
                  </Layout>)
                }

                export default #{@path.component_name}
              JSX
            end

            def test_content
              <<~JS
                import React from 'react'
                import { render, screen } from '@testing-library/react'
                import #{@path.component_name} from './#{@path.component_name}'

                describe('#{@path.component_name}', () => {
                  it('renders', () => {
                    render(<#{@path.component_name} />)

                    expect(
                      screen.getByText('#{@path.display_path}')
                    ).toBeInTheDocument()
                  })
                })
              JS
            end
          end
        end
      end
    end
  end
end
