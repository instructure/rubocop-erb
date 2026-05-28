# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Ensures there is exactly one space before the closing ERB tag, when the
      # closing tag is on the same line as the tag's content.
      #
      # @example
      #   # bad
      #   <% do_something%>
      #   <% do_something  %>
      #
      #   # good
      #   <% do_something %>
      class SpaceBeforeClosingTag < Base
        include ERBVisitor
        extend AutoCorrector

        MSG_MISSING = 'Add a space before the closing ERB tag.'
        MSG_EXTRA = 'Use a single space before the closing ERB tag.'

        def visit_erb_node(node)
          content = node.content
          return unless content

          # Only consider whitespace that sits between the Ruby content and the
          # closing tag on the same line. A run preceded by a newline (or empty
          # content) means the closing tag is on its own line, which is handled
          # by the tag alignment cops instead.
          trailing = content.value[/[^\S\n]*\z/]
          before = content.value[0...(content.value.length - trailing.length)]
          return if before.empty? || before.end_with?("\n")

          if trailing.empty?
            add_offense(node.tag_closing, message: MSG_MISSING) do |corrector|
              corrector.replace(node.tag_closing, " #{node.tag_closing.value}")
            end
          elsif trailing.length > 1
            extra = range_before(content.location.end, trailing.length - 1)
            add_offense(extra, message: MSG_EXTRA) do |corrector|
              corrector.remove(extra)
            end
          end
        end
      end
    end
  end
end
