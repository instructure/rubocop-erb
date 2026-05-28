# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Ensures the closing `<% end %>` of a block that spans multiple ERB tags
      # is aligned with the column of the tag that opens the block.
      #
      # @example
      #   # bad
      #   <% items.each do |item| %>
      #     <%= item %>
      #     <% end %>
      #
      #   # good
      #   <% items.each do |item| %>
      #     <%= item %>
      #   <% end %>
      class BlockAlignment < Base
        include ERBVisitor
        extend AutoCorrector

        MSG = '%<current>s is not aligned with %<prefer>s.'

        def visit_erb_block_node(node)
          start_location = node.tag_opening.location.start
          end_location = node.end_node.tag_opening.location.start
          return if start_location.line == end_location.line || start_location.column == end_location.column

          end_node = node.end_node
          current = "#{end_node.tag_opening.value}#{end_node.content.value}#{end_node.tag_closing.value}"
          prefer = "#{node.tag_opening.value} at #{node.tag_opening.location.start.tree_inspect}"
          message = format(MSG, current: current, prefer: prefer)
          add_offense(node.end_node.tag_opening, message: message) do |corrector|
            difference = end_location.column - start_location.column
            if difference.negative?
              corrector.insert_before(end_location, ' ' * -difference)
            else
              range = range_before(end_location, difference)
              # Only dedent by removing whitespace; never delete content that
              # happens to share the `<% end %>` line.
              corrector.remove(range) if whitespace_only?(range)
            end
          end
        end

        private

        # @return [Boolean] whether the original template text for the range is
        #   only whitespace
        def whitespace_only?(range)
          processed_source.template_source[range.begin_pos...range.end_pos].to_s.match?(/\A\s*\z/)
        end
      end
    end
  end
end
