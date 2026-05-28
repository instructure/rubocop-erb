# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      module Layout
        # Prevents `Layout/IndentationConsistency` from comparing statements that
        # live in different ERB tags. Each tag's statements are only checked for
        # consistency against their own tag-mates, so indentation that differs
        # from code in a neighbouring tag is not flagged.
        module IndentationConsistency
          def check_alignment(
            items,
            base_column = nil
          )
            return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)

            group_by_erb_node(items).each_value do |group|
              super(group, base_column)
            end
          end

          private

          # @return [Hash] items grouped by the ERB node that contains them,
          #   preserving their original order within each group
          def group_by_erb_node(items)
            items.group_by do |item|
              processed_source.erb_node_for_pos(item.source_range.begin_pos)
            end
          end
        end
      end
    end
  end
end
