# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Ignores offenses for things up against an ERB closing tag
      # it will be handled by ERB/TrailingWhitespace instead
      module IgnoreAtEndOfERBNode
        def add_offense(
          range,
          ...
        )
          return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)
          return unless (node = processed_source.erb_node_for_pos(range.begin_pos))

          closing_tag_start = processed_source.herb_position_to_buffer_pos(node.tag_closing.location.start)
          return if range.end_pos >= closing_tag_start

          super
        end
      end
    end
  end
end
