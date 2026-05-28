# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Disallows the `<%==` raw output tag, which emits its value without HTML
      # escaping (equivalent to `<%= raw(...) %>`).
      #
      # This only applies when `Rails/OutputSafety` is enabled for the file, so
      # the two cops agree on whether unescaped output is allowed.
      #
      # @example
      #   # bad
      #   <%== user_input %>
      #
      #   # good
      #   <%= user_input %>
      class OutputSafety < Base
        MSG = 'The raw output tag `<%==` bypasses HTML escaping and may be a security risk.'

        RAW_OUTPUT_TAG = '<%=='

        include ERBVisitor

        def visit_erb_node(node)
          return unless node.tag_opening&.value == RAW_OUTPUT_TAG
          return unless config.cop_enabled?('Rails/OutputSafety')

          add_offense(node.tag_opening)
        end
      end
    end
  end
end
