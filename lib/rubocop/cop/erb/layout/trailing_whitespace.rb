# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      module Layout
        # Prevents offenses for a pure whitespace line at the end of an ERB node
        # which will be handled by ERB/TagAlignment
        module TrailingWhitespace
          def add_offense(
            range,
            ...
          )
            return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)

            # The extracted Ruby blanks ERB tag delimiters to spaces, so an
            # opening tag at the end of a line (e.g. `... %><%=`) looks like
            # trailing whitespace. When the original template is not actually
            # whitespace there, the line does not really end in whitespace.
            return if processed_source.template_source[range.begin_pos...range.end_pos].to_s.match?(/\S/)
            return unless (node = processed_source.erb_node_for_pos(range.begin_pos))

            line = processed_source.buffer.line_for_position(range.begin_pos)
            # empty final line; ignore
            return if processed_source.buffer.line_range(line).begin_pos == range.begin_pos

            # trim the ERB tag itself from the range
            if line == node.location.end.line
              trimmed_end = range.end_pos - node.tag_closing.value.length - 1
              # When the whitespace run is no longer than the (blanked) closing
              # tag, there is nothing to trim down to; let the other patches in
              # the chain (e.g. IgnoreAtEndOfErbNode) decide.
              if trimmed_end > range.begin_pos
                range = Parser::Source::Range.new(processed_source.buffer, range.begin_pos, trimmed_end)
                # overwrite corrector to use the new range
                return super do |corrector|
                  corrector.remove(range)
                end
              end
            end

            super
          end
        end
      end
    end
  end
end
