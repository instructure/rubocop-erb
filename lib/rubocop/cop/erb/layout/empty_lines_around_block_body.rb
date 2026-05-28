# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      module Layout
        # The body of an ERB block spans template content between tags, so a blank
        # line within it is usually output formatting (e.g. a markdown paragraph
        # break), not Ruby whitespace inside the block. Only an empty line that
        # falls within a single ERB tag's Ruby content is a real offense.
        module EmptyLinesAroundBlockBody
          def add_offense(
            range,
            ...
          )
            return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)

            range = range_from_node_or_range(range)
            return super if processed_source.range_within_ruby_content?(range.begin_pos, range.end_pos)

            nil
          end
        end
      end
    end
  end
end
