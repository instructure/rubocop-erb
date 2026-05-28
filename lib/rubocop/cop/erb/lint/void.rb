# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      module Lint
        # Prevents offenses for the rendered expression of an output ERB node
        # (`<%= %>` or `<%== %>`). An output tag renders the value of its *last*
        # statement, so anything within that statement is used rather than
        # discarded. Earlier statements in the same tag (e.g. `<%= foo; bar %>`)
        # are still void and remain reportable.
        #
        # This is checked against the node actually being reported (rather than,
        # say, the enclosing statement) because a single Ruby expression can span
        # several ERB tags -- e.g. an `if` opened in a `<% %>` tag whose branch is
        # rendered by a nested `<%= %>` tag.
        module Void
          include RenderedStatement

          def add_offense(
            range,
            ...
          )
            return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)

            range = range_from_node_or_range(range)
            return super unless (node = processed_source.erb_node_for_pos(range.begin_pos))
            return super unless (rendered = rendered_statement(node))

            return if range.begin_pos >= rendered.source_range.begin_pos

            super
          end
        end
      end
    end
  end
end
