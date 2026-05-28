# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      module Layout
        # `Layout/IndentationWidth` records every offending body's range (in
        # `other_offense_in_same_range?`) so that nested indentation offenses are
        # left for a later autocorrect pass, once the outer one is fixed. It does
        # this bookkeeping even for offenses that `IgnoreAtStartOfERBNode` goes on
        # to suppress -- so a suppressed outer offense (code at the start of an
        # ERB tag) poisons the autocorrect of every offense nested within it, and
        # because the outer offense is never corrected, the inner ones never
        # converge.
        #
        # Skip the offense entirely (and therefore the range bookkeeping) when it
        # would be suppressed anyway, so nested offenses stay autocorrectable.
        module IndentationWidth
          def offense(
            body_node,
            indentation,
            style = 'normal'
          )
            return if at_start_of_erb_node?(offending_range(body_node, indentation))

            super
          end
        end
      end
    end
  end
end
