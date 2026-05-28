# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      module Layout
        # Prevents `Layout/CommentIndentation` from measuring a comment against a
        # line that is not Ruby content of the same ERB tag -- most notably the
        # closing `%>` (which extraction turns into a `;`). Such comparisons are
        # meaningless, so `line_after_comment` returns nil (treated as column 0).
        module CommentIndentation
          def line_after_comment(comment)
            line = super
            return line unless line && processed_source.is_a?(RuboCop::Erb::ERBSource)
            return line if next_line_in_same_tag?(comment, line)

            # When the next non-blank line is not Ruby content of the comment's
            # own ERB tag (e.g. the closing `%>`), there is nothing meaningful to
            # align against, so measure the comment against itself -- yielding a
            # zero column delta and no offense regardless of its indentation.
            processed_source.lines[comment.loc.line - 1]
          end

          private

          # @return [Integer, nil] buffer position of the first non-blank character
          #   of +line+, located at or after the comment
          def line_position(
            comment,
            line
          )
            offset = processed_source.lines[comment.loc.line..]&.index(line)
            return unless offset

            line_range = processed_source.buffer.line_range(comment.loc.line + 1 + offset)
            line_range.begin_pos + (line =~ /\S/ || 0)
          end

          # @return [Boolean] whether the given next non-blank line's Ruby still
          #   belongs to the content of the comment's own ERB tag
          def next_line_in_same_tag?(
            comment,
            line
          )
            node = processed_source.erb_node_for_pos(comment.loc.expression.begin_pos)
            return true unless node

            content_end = processed_source.herb_position_to_buffer_pos(node.content.location.end)
            (position = line_position(comment, line)) && position < content_end
          end
        end
      end
    end
  end
end
