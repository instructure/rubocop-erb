# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Ensures there is a space after the opening ERB tag.
      #
      # @example
      #   # bad
      #   <%do_something %>
      #   <%=value %>
      #
      #   # good
      #   <% do_something %>
      #   <%= value %>
      class SpaceAfterOpeningTag < Base
        include ERBVisitor
        extend AutoCorrector

        MSG = 'Add a space after the opening ERB tag.'

        def visit_erb_node(node)
          return if node.content.value.match?(/\A\s/)

          add_offense(node.tag_opening, message: MSG) do |corrector|
            corrector.replace(node.tag_opening, "#{node.tag_opening.value} ")
          end
        end
      end
    end
  end
end
