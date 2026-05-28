# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Looks for trailing blank lines and a final newline in an ERB template.
      #
      # This is an analog of `Layout/TrailingEmptyLines` that operates on the raw
      # template instead of the extracted Ruby, so trailing HTML/text is measured
      # correctly (the extracted Ruby blanks it to whitespace).
      #
      # @example EnforcedStyle: final_newline (default)
      #   # bad - missing or extra trailing newlines
      #   # good - exactly one newline at the end of the file
      #
      # @example EnforcedStyle: final_blank_line
      #   # good - one blank line followed by a newline at the end of the file
      class TrailingEmptyLines < Base
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        def on_new_investigation
          return unless processed_source.is_a?(RuboCop::Erb::ERBSource)

          source = processed_source.template_source
          return if source.empty?

          whitespace_at_end = source[/\s*\Z/]
          blank_lines = whitespace_at_end.count("\n") - 1
          wanted_blank_lines = style == :final_newline ? 0 : 1
          return if blank_lines == wanted_blank_lines

          register_offense(source, whitespace_at_end, wanted_blank_lines, blank_lines)
        end

        private

        def message(
          wanted_blank_lines,
          blank_lines
        )
          case blank_lines
          when -1 then 'Final newline missing.'
          when 0 then 'Trailing blank line missing.'
          else
            instead_of = wanted_blank_lines.zero? ? '' : "instead of #{wanted_blank_lines} "
            format('%<current>d trailing blank lines %<prefer>sdetected.', current: blank_lines, prefer: instead_of)
          end
        end

        def register_offense(
          source,
          whitespace_at_end,
          wanted_blank_lines,
          blank_lines
        )
          buffer = processed_source.buffer
          begin_pos = source.length - whitespace_at_end.length
          autocorrect_range = Parser::Source::Range.new(buffer, begin_pos, source.length)
          report_begin = whitespace_at_end.empty? ? begin_pos : begin_pos + 1
          report_range = Parser::Source::Range.new(buffer, report_begin, source.length)

          add_offense(report_range, message: message(wanted_blank_lines, blank_lines)) do |corrector|
            corrector.replace(autocorrect_range, style == :final_newline ? "\n" : "\n\n")
          end
        end
      end
    end
  end
end
