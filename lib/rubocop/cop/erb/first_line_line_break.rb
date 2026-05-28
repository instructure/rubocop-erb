# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Checks for a line break before the first line of code in a multi-line ERB
      # tag, mirroring `Layout/FirstArrayElementLineBreak` with the opening ERB tag
      # (`<%`) in place of the array's opening bracket.
      #
      # When a tag's code spans multiple lines, the first line of code must not be
      # on the same line as the opening tag.
      #
      # @example
      #   # bad
      #   <% foo(a,
      #          b) %>
      #
      #   # good
      #   <%
      #     foo(a,
      #         b) %>
      #
      #   # good (single line of code)
      #   <% foo(a, b) %>
      class FirstLineLineBreak < Base
        include ERBVisitor
        extend AutoCorrector

        MSG = 'Add a line break before the first line of code in a multi-line ERB tag.'

        def visit_erb_node(node)
          return unless (content = node.content)

          value = content.value
          return unless (first_offset = value.index(/\S/))

          start_line = content.location.start.line
          first_line = start_line + value[0...first_offset].count("\n")
          last_line = start_line + value[0...value.rindex(/\S/)].count("\n")

          # Already broken onto its own line, or the code is only a single line.
          return unless first_line == node.tag_opening.location.start.line
          return if first_line == last_line

          add_offense(offense_range(node, content, first_offset)) do |corrector|
            corrector.replace(leading_range(node, content, first_offset), "\n#{indent(node)}")
          end
        end

        private

        def indent(node)
          ' ' * (node.tag_opening.location.start.column + 2)
        end

        # The whitespace between the opening tag and the first line of code.
        def leading_range(
          node,
          content,
          first_offset
        )
          buffer = processed_source.buffer
          opening_end = processed_source.herb_position_to_buffer_pos(node.tag_opening.location.end)
          content_begin = processed_source.herb_position_to_buffer_pos(content.location.start)
          Parser::Source::Range.new(buffer, opening_end, content_begin + first_offset)
        end

        # The first line of code through the end of the opening tag's line.
        def offense_range(
          node,
          content,
          first_offset
        )
          buffer = processed_source.buffer
          first_pos = processed_source.herb_position_to_buffer_pos(content.location.start) + first_offset
          line_end = buffer.line_range(node.tag_opening.location.start.line).end_pos
          Parser::Source::Range.new(buffer, first_pos, line_end)
        end
      end
    end
  end
end
