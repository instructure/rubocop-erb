# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      module Lint
        # Prevents false `Lint/EmptyWhen` offenses for `case` statements whose
        # branches span multiple ERB tags.
        #
        # A `when` branch's body is often non-Ruby (HTML/text) content in a
        # separate ERB tag, which is blanked out during Ruby extraction and so
        # looks empty. A `case` contained within a single ERB tag is pure Ruby and
        # is still checked normally.
        module EmptyWhen
          def on_case(node)
            return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)

            # When the `case` spans several ERB tags, the branch bodies are
            # non-Ruby content we can't see; only check pure single-tag cases.
            range = node.source_range
            return unless processed_source.range_within_single_erb_node?(range.begin_pos, range.end_pos)

            super
          end
        end
      end
    end
  end
end
