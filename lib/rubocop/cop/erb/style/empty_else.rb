# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      module Style
        # Prevents offenses for semicolons inserted to make multiple ERB tags on the same line valid syntax
        module EmptyElse
          def add_offense(
            range,
            ...
          )
            return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)
            return unless (if_node = else_ranges[range])

            end_loc = if_node.loc.end || if_node.parent.loc.end
            return unless processed_source.erb_node_for_pos(if_node.loc.else.begin_pos) ==
                          processed_source.erb_node_for_pos(end_loc.begin_pos)

            super
          end

          private

          def else_ranges
            @else_ranges ||= begin
              ranges = {}
              processed_source.ast.each_node(:if) do |node|
                ranges[node.loc.else] = node if node.else?
              end
              ranges
            end
          end
        end
      end
    end
  end
end
