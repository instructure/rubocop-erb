# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Checks for a redundant `to_s` on the value rendered by an output ERB tag
      # (`<%=` or `<%==`). ERB already calls `to_s` on the rendered value, so an
      # explicit `to_s` on its final statement is redundant.
      #
      # Earlier statements in a multi-statement tag (e.g. `<%= foo.to_s; bar %>`)
      # are not rendered and are left alone.
      #
      # @example
      #   # bad
      #   <%= user.name.to_s %>
      #   <%= foo; bar.to_s %>
      #
      #   # good
      #   <%= user.name %>
      #   <%= foo; bar %>
      class RedundantStringCoercion < Base
        include ERBVisitor
        include RenderedStatement
        extend AutoCorrector

        MSG = 'Redundant use of `Object#to_s` on the value rendered by an ERB output tag.'

        # @!method redundant_coercion?(node)
        def_node_matcher :redundant_coercion?, '(call !nil? :to_s)'

        def visit_erb_node(node)
          return unless (rendered = rendered_statement(node))
          return unless redundant_coercion?(rendered)

          add_offense(rendered.loc.selector) do |corrector|
            corrector.replace(rendered, rendered.receiver.source)
          end
        end
      end
    end
  end
end
