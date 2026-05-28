# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Ensures an ERB tag does not begin with extra leading whitespace. A
      # single-line tag should have just one space after the opening tag, and a
      # multi-line tag should start its content on the next line rather than
      # after trailing spaces on the opening line.
      #
      # @example
      #   # bad
      #   <%   do_something %>
      #
      #   # good
      #   <% do_something %>
      class LeadingWhitespace < Base
        include ERBVisitor
        extend AutoCorrector

        MSG = 'Leading whitespace detected.'

        def visit_erb_node(node)
          value = node.content.value
          return unless (match = value.match(/\A[ \t\r\f\v]{2,}/) || value.match(/\A\s+\n/))

          range = range_after(node.tag_opening.location.end, match[0].length)
          add_offense(range, message: MSG) do |corrector|
            corrector.replace(range, match[0].include?("\n") ? "\n" : ' ')
          end
        end
      end
    end
  end
end
