# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      module Style
        # Prevents false `Style/IdenticalConditionalBranches` offenses for ERB
        # conditionals whose branches span multiple ERB tags.
        #
        # Branches that look identical in the extracted Ruby often differ in their
        # non-Ruby (HTML/text) content, which is blanked out during extraction, so
        # the suggestion to hoist the common code out of the conditional would
        # change what is rendered. A conditional contained within a single ERB tag
        # is pure Ruby and is still checked normally.
        module IdenticalConditionalBranches
          def on_case(node)
            return if skip_erb_branches?(node)

            super
          end

          def on_case_match(node)
            return if skip_erb_branches?(node)

            super
          end

          def on_if(node)
            return if skip_erb_branches?(node)

            super
          end

          private

          def skip_erb_branches?(node)
            return false unless processed_source.is_a?(RuboCop::Erb::ERBSource)

            range = node.source_range
            !processed_source.range_within_single_erb_node?(range.begin_pos, range.end_pos)
          end
        end
      end
    end
  end
end
