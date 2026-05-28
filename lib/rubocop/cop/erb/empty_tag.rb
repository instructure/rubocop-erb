# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Removes ERB tags whose content is only whitespace, e.g. `<% %>`.
      #
      # Such tags render nothing and run no code, so they are just noise.
      # Escape tags (`<%% %>`) are left alone because they render a literal
      # `<% %>`.
      #
      # @example
      #   # bad
      #   <div><% %></div>
      #
      #   # good
      #   <div></div>
      class EmptyTag < Base
        include ERBVisitor
        extend AutoCorrector

        MSG = 'Remove the empty ERB tag.'

        # Escape tags render a literal `<% %>`, so they are not empty.
        ESCAPE_TAG_OPENING = '<%%'

        def visit_erb_node(node)
          return if node.tag_opening&.value == ESCAPE_TAG_OPENING
          return unless node.content.value.match?(/\A\s*\z/)

          add_offense(node) do |corrector|
            corrector.remove(node)
          end
        end
      end
    end
  end
end
