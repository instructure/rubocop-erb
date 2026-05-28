# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Checks that the closing tag of a multi-line ERB tag is either on the same
      # line as the last content or on a new line, mirroring
      # `Layout/MultilineArrayBraceLayout` with the ERB tags (`<% %>`) in place of
      # the array brackets.
      #
      # When using the `symmetrical` (default) style:
      #
      # If the opening tag is on the same line as the first content, then the
      # closing tag should be on the same line as the last content. If the opening
      # tag is on its own line, then the closing tag should be too.
      #
      # When using the `new_line` style, the closing tag must be on the line after
      # the last content. When using the `same_line` style, the closing tag must
      # be on the same line as the last content.
      #
      # @example EnforcedStyle: symmetrical (default)
      #   # bad
      #   <% foo(a,
      #          b)
      #   %>
      #
      #   # bad
      #   <%
      #     foo(a,
      #         b) %>
      #
      #   # good
      #   <% foo(a,
      #          b) %>
      #
      #   # good
      #   <%
      #     foo(a,
      #         b)
      #   %>
      #
      # @example EnforcedStyle: new_line
      #   # bad
      #   <% foo(a,
      #          b) %>
      #
      #   # good
      #   <% foo(a,
      #          b)
      #   %>
      #
      # @example EnforcedStyle: same_line
      #   # bad
      #   <% foo(a,
      #          b)
      #   %>
      #
      #   # good
      #   <% foo(a,
      #          b) %>
      class MultilineTagLayout < Base
        include ERBVisitor
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        SAME_LINE_MESSAGE = 'The closing ERB tag must be on the same line as the last content when the ' \
                            'opening tag is on the same line as the first content.'

        NEW_LINE_MESSAGE = 'The closing ERB tag must be on the line after the last content when the ' \
                           'opening tag is on a separate line from the first content.'

        ALWAYS_NEW_LINE_MESSAGE = 'The closing ERB tag must be on the line after the last content.'

        ALWAYS_SAME_LINE_MESSAGE = 'The closing ERB tag must be on the same line as the last content.'

        OPENING_NEW_LINE_MESSAGE = 'The opening ERB tag must be on its own line when the last content ' \
                                   'is a heredoc, since the closing tag cannot share that line.'

        def visit_erb_node(node)
          return unless (layout = tag_layout(node))

          case style
          when :symmetrical then check_symmetrical(node, layout)
          when :new_line then check_new_line(node, layout)
          when :same_line then check_same_line(node, layout)
          end
        end

        private

        def check_new_line(
          node,
          layout
        )
          return unless layout[:closing_on_last_line]

          add_offense(node.tag_closing, message: ALWAYS_NEW_LINE_MESSAGE) do |corrector|
            correct_to_new_line(corrector, node, layout)
          end
        end

        def check_same_line(
          node,
          layout
        )
          return if layout[:closing_on_last_line]
          # The closing tag cannot share a heredoc sentinel line, so leave it.
          return if heredoc_on_last_line?(node, layout)

          add_offense(node.tag_closing, message: ALWAYS_SAME_LINE_MESSAGE) do |corrector|
            correct_to_same_line(corrector, node, layout)
          end
        end

        def check_symmetrical(
          node,
          layout
        )
          if heredoc_on_last_line?(node, layout)
            # The heredoc forces the closing tag onto its own line, so move the
            # opening tag onto its own line too -- never the closing tag, which
            # would merge `%>` into the heredoc sentinel and break it.
            return unless layout[:opening_on_first_line]

            add_offense(node.tag_opening, message: OPENING_NEW_LINE_MESSAGE) do |corrector|
              correct_opening_to_new_line(corrector, node, layout)
            end
          elsif layout[:opening_on_first_line]
            return if layout[:closing_on_last_line]

            add_offense(node.tag_closing, message: SAME_LINE_MESSAGE) do |corrector|
              correct_to_same_line(corrector, node, layout)
            end
          else
            return unless layout[:closing_on_last_line]

            add_offense(node.tag_closing, message: NEW_LINE_MESSAGE) do |corrector|
              correct_to_new_line(corrector, node, layout)
            end
          end
        end

        def correct_opening_to_new_line(
          corrector,
          node,
          layout
        )
          indent = ' ' * (node.tag_opening.location.start.column + 2)
          corrector.replace(leading_range(node, layout), "\n#{indent}")
        end

        def correct_to_new_line(
          corrector,
          node,
          layout
        )
          indent = ' ' * node.tag_opening.location.start.column
          corrector.replace(trailing_range(node, layout), "\n#{indent}")
        end

        def correct_to_same_line(
          corrector,
          node,
          layout
        )
          corrector.replace(trailing_range(node, layout), ' ')
        end

        # @return [Boolean] whether the last content line is a heredoc's closing
        #   sentinel (so the closing tag must stay on its own line)
        def heredoc_on_last_line?(
          node,
          layout
        )
          return false unless (ast = processed_source.ast)

          content_begin = processed_source.herb_position_to_buffer_pos(node.content.location.start)
          content_end = processed_source.herb_position_to_buffer_pos(node.content.location.end)
          ast.each_node(:str, :dstr, :xstr).any? do |str|
            next false unless str.heredoc?

            heredoc_end = str.loc.heredoc_end
            heredoc_end.line == layout[:last_line] &&
              heredoc_end.begin_pos >= content_begin && heredoc_end.end_pos <= content_end
          end
        end

        # The whitespace between the opening tag and the first content.
        def leading_range(
          node,
          layout
        )
          opening_end = processed_source.herb_position_to_buffer_pos(node.tag_opening.location.end)
          content_begin = processed_source.herb_position_to_buffer_pos(node.content.location.start)
          Parser::Source::Range.new(processed_source.buffer, opening_end, content_begin + layout[:first_offset])
        end

        # @return [Hash, nil] line relationships, or nil when the tag is single
        #   line or has no content
        def tag_layout(node)
          return unless (content = node.content)

          value = content.value
          return unless (first_offset = value.index(/\S/))

          opening_line = node.tag_opening.location.start.line
          closing_line = node.tag_closing.location.start.line
          return if opening_line == closing_line

          last_offset = value.rindex(/\S/)
          start_line = content.location.start.line
          last_line = start_line + value[0...last_offset].count("\n")
          {
            closing_on_last_line: closing_line == last_line,
            first_offset: first_offset,
            last_line: last_line,
            last_offset: last_offset,
            opening_on_first_line: opening_line == start_line + value[0...first_offset].count("\n")
          }
        end

        # The whitespace between the last content character and the closing tag.
        def trailing_range(
          node,
          layout
        )
          content_begin = processed_source.herb_position_to_buffer_pos(node.content.location.start)
          last_content_end = content_begin + layout[:last_offset] + 1
          closing_begin = processed_source.herb_position_to_buffer_pos(node.tag_closing.location.start)
          Parser::Source::Range.new(processed_source.buffer, last_content_end, closing_begin)
        end
      end
    end
  end
end
