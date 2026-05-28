# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      module Lint
        # Prevents false `Lint/DuplicateBranch` offenses for ERB conditionals
        # whose branches span multiple ERB tags.
        #
        # Such branches include non-Ruby (HTML/text) content that is blanked out
        # during Ruby extraction, so branches that look identical in Ruby may
        # render differently. We can't tell from the extracted Ruby, so we assume
        # they differ and skip the check. A conditional contained within a single
        # ERB tag is pure Ruby and is still checked normally.
        module DuplicateBranch
          def on_branching_statement(node)
            return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)

            range = node.source_range
            return super if processed_source.range_within_single_erb_node?(range.begin_pos, range.end_pos)

            # Branches span multiple ERB tags and therefore include non-Ruby
            # content we assume to differ; leave them unreported.
            nil
          end

          def on_case(node)
            on_branching_statement(node)
          end

          def on_case_match(node)
            on_branching_statement(node)
          end

          def on_rescue(node)
            on_branching_statement(node)
          end
        end
      end
    end
  end
end
