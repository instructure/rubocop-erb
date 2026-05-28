# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Checks for unnecessary blank lines at the beginning of an ERB template.
      #
      # This is an analog of `Layout/LeadingEmptyLines` that operates on the raw
      # template instead of the extracted Ruby, so HTML at the top of the file is
      # recognized as content rather than treated as blank.
      #
      # @example
      #   # bad
      #
      #   <div></div>
      #
      #   # good
      #   <div></div>
      class LeadingEmptyLines < Base
        extend AutoCorrector

        MSG = 'Unnecessary blank line at the beginning of the source.'

        def on_new_investigation
          return unless processed_source.is_a?(RuboCop::Erb::ERBSource)
          return unless (first = processed_source.template_source.index(/\S/))

          buffer = processed_source.buffer
          line = buffer.line_for_position(first)
          return unless line > 1

          line_begin = buffer.line_range(line).begin_pos
          add_offense(Parser::Source::Range.new(buffer, first, first + 1)) do |corrector|
            corrector.remove(Parser::Source::Range.new(buffer, 0, line_begin))
          end
        end
      end
    end
  end
end
