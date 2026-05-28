# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Ensures that when an ERB tag spans multiple lines, its closing `%>` (on
      # its own line) is aligned with the column of the opening tag.
      #
      # @example
      #   # bad
      #   <%
      #     do_something
      #     %>
      #
      #   # good
      #   <%
      #     do_something
      #   %>
      class TagAlignment < Base
        include ERBVisitor
        extend AutoCorrector

        MSG = 'Align ERB closing tags with their opening tag.'

        def visit_erb_node(node)
          return if node.location.start.line == node.location.end.line
          return unless (match = node.content.value.match(/\n[ \t\r\f\v]*\z/))
          return if node.tag_opening.location.start.column == node.tag_closing.location.start.column

          add_offense(node.tag_closing, message: MSG) do |corrector|
            range = range_before(node.content.location.end, match[0].length)
            corrector.replace(range, "\n#{' ' * node.tag_opening.location.start.column}")
          end
        end
      end
    end
  end
end
