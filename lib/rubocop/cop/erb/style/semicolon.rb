# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      module Style
        # Prevents offenses for semicolons inserted to make multiple ERB tags on the same line valid syntax
        module Semicolon
          def add_offense(
            range,
            ...
          )
            return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)

            # When a line holds several ERB tags, the extracted Ruby reads as
            # multiple expressions, so `Style/Semicolon` regex-scans the line for
            # `;` -- which also matches semicolons inside string/regexp literals.
            # Only a real semicolon token is an offense.
            return unless semicolon_token?(range.begin_pos)
            return unless (node = processed_source.erb_node_for_pos(range.begin_pos))
            return unless range.begin_pos > processed_source.herb_position_to_buffer_pos(node.content.location.start)
            return unless range.end_pos < processed_source.herb_position_to_buffer_pos(node.content.location.end)

            super
          end

          private

          def semicolon_token?(position)
            processed_source.tokens.any? { |token| token.semicolon? && token.begin_pos == position }
          end
        end
      end
    end
  end
end
