# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Prevents offenses for Ruby nodes spanning multiple ERB nodes
      module IgnoreAcrossERBNodes
        def add_offense(
          range,
          ...
        )
          return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)

          range = range_from_node_or_range(range)
          return if processed_source.erb_node_for_pos(range.begin_pos) !=
                    processed_source.erb_node_for_pos(range.end_pos)

          super
        end
      end
    end
  end
end
