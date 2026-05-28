# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Ignores offenses for indentation consistency against an ERB opening tag
      module IgnoreAtStartOfERBNode
        def add_offense(
          range,
          ...
        )
          return if at_start_of_erb_node?(range)

          super
        end

        private

        # @return [Boolean] whether the offense range falls at (or before) the
        #   first code in its ERB tag, so it is measured against the opening tag
        #   rather than sibling code. Non-ERB sources are never at a start.
        def at_start_of_erb_node?(range)
          return false unless processed_source.is_a?(RuboCop::Erb::ERBSource)

          range = range_from_node_or_range(range)
          # A position outside any ERB tag has no meaningful opening tag to align
          # against, so treat it as a start and leave it alone.
          return true unless (node = processed_source.erb_node_for_pos(range.begin_pos))

          first_non_whitespace_pos = processed_source.herb_position_to_buffer_pos(node.content.location.start) +
                                     (node.content.value.index(/\S/) || 0)
          range.begin_pos <= first_non_whitespace_pos
        end
      end
    end
  end
end
