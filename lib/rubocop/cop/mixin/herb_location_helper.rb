# frozen_string_literal: true

require 'herb'

module RuboCop
  module Cop
    module HerbLocationHelper
      # @param [Herb::Position] position
      # @param [Integer] length
      # @return [Parser::Source::Range]
      def range_after(
        position,
        length
      )
        start_pos = processed_source.herb_position_to_buffer_pos(position)
        Parser::Source::Range.new(processed_source.buffer, start_pos, start_pos + length)
      end

      # @param [Herb::Position] position
      # @param [Integer] length
      # @return [Parser::Source::Range]
      def range_before(
        position,
        length
      )
        end_pos = processed_source.herb_position_to_buffer_pos(position)
        Parser::Source::Range.new(processed_source.buffer, end_pos - length, end_pos)
      end

      private

      def range_from_node_or_range(node_or_range)
        node_or_range = processed_source.to_range(node_or_range)
        super
      end
    end
  end
end
