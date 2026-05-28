# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Ensures the first line of code after the opening line of a multi-line
      # ERB tag is indented appropriately.
      #
      # When there is code on the same line as the opening tag, the following
      # line must be indented one character deeper than the end of the opening
      # tag (so 3 spaces for `<%`, 4 for `<%=`, and 5 for `<%==`). When the
      # opening tag is on a line of its own, the following line must be indented
      # by the configured `IndentationWidth`. An ERB comment tag (`<%#`) is a
      # special case: its content is aligned with the `#` (2 spaces).
      #
      # @example
      #   # bad
      #   <%#
      #       comment
      #   %>
      #
      #   # good
      #   <%#
      #     comment
      #   %>
      #
      #   # bad
      #   <% foo
      #     bar %>
      #
      #   # good
      #   <% foo
      #      bar %>
      #
      #   # bad
      #   <%
      #       foo
      #     bar
      #   %>
      #
      #   # good
      #   <%
      #     foo
      #     bar
      #   %>
      #
      # @example AllowZeroIndentForInitialBlockComment: true (default)
      #   # good
      #   <%
      #   # Copyright (C) 2024 Acme
      #   #
      #   # This file is part of something.
      #   %>
      #
      # @example AllowZeroIndentForInitialBlockComment: false
      #   # bad
      #   <%
      #   # Copyright (C) 2024 Acme
      #   %>
      class Indentation < Base
        include ERBVisitor
        include Alignment
        extend AutoCorrector

        MSG = 'Use %<expected>d spaces for indentation of the first line in a multi-line ERB tag.'

        def visit_erb_node(node)
          return unless (content = node.content)

          segments = content.value.split("\n", -1)
          return unless (check_index = first_line_after_opening(segments))

          code_on_opening_line = segments.first.match?(/\S/)
          expected = expected_indent(node, code_on_opening_line)
          actual = segments[check_index].index(/\S/)
          return if actual == expected
          return if allowed_initial_block_comment?(node, segments, code_on_opening_line)

          line_range = processed_source.buffer.line_range(content.location.start.line + check_index)
          # A continuation of a multi-line expression that opened on an earlier
          # line (method arguments, array/hash elements, a heredoc body, a block,
          # etc.) is aligned by the relevant `Layout/*Alignment` cop, not here.
          return if continuation_line?(line_range.begin_pos + actual)

          register(line_range, actual, expected)
        end

        private

        # The license-header exception: a plain `<%` tag at the very top of the
        # file whose only content is comments (or a single `=begin`/`=end` block)
        # is allowed to keep its comments flush against column 0.
        def allowed_initial_block_comment?(
          node,
          segments,
          code_on_opening_line
        )
          return false unless cop_config['AllowZeroIndentForInitialBlockComment']
          return false unless node.tag_opening.value == '<%'
          return false unless node.tag_opening.location.start.line == 1
          return false unless node.tag_opening.location.start.column.zero?
          return false if code_on_opening_line

          lines = segments[1..].reject { |line| line.strip.empty? }
          return false if lines.empty?

          lines.all? { |line| line.start_with?('#') } ||
            (lines.first.start_with?('=begin') && lines.last.start_with?('=end'))
        end

        # @return [Boolean] whether +position+ falls in the interior of a multi-line
        #   AST node that began on an earlier line, i.e. it continues an expression
        #   rather than starting a new statement. A bare statement sequence
        #   (`begin`) is not such a structure -- its children are separate
        #   statements this cop should still indent.
        def continuation_line?(position)
          return false unless (ast = processed_source.ast)

          line = processed_source.buffer.line_for_position(position)
          ast.each_node.any? do |node|
            next false if node.begin_type? || node.kwbegin_type?
            next false unless (range = node.source_range)

            range.begin_pos < position && range.end_pos > position && range.first_line < line
          end
        end

        def expected_indent(
          node,
          code_on_opening_line
        )
          column = node.tag_opening.location.start.column
          # An ERB comment tag (`<%#`) aligns its content with the `#`.
          return column + 2 if node.tag_opening.value == '<%#'

          if code_on_opening_line
            column + node.tag_opening.value.length + 1
          else
            column + configured_indentation_width
          end
        end

        # @return [Integer, nil] index into +segments+ of the first line, after the
        #   opening tag's line, that contains code (nil when there is none)
        def first_line_after_opening(segments)
          (1...segments.length).find { |index| segments[index].match?(/\S/) }
        end

        def register(
          line_range,
          actual,
          expected
        )
          buffer = processed_source.buffer
          add_offense(
            Parser::Source::Range.new(buffer, line_range.begin_pos + actual, line_range.end_pos),
            message: format(MSG, expected: expected)
          ) do |corrector|
            corrector.replace(
              Parser::Source::Range.new(buffer, line_range.begin_pos, line_range.begin_pos + actual),
              ' ' * expected
            )
          end
        end
      end
    end
  end
end
