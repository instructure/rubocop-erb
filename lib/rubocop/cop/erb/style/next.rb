# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      module Style
        # Prevents false `Style/Next` offenses when the trailing conditional of a
        # loop lives in a separate ERB tag and there is non-Ruby (HTML/text)
        # content between it and the loop -- extraction blanks that content out, so
        # the conditional looks like the last statement when it is not. Rewriting
        # to `next` would drop or misplace that markup.
        #
        # When the loop and its conditional are pure Ruby in one ERB tag (or only
        # whitespace separates them), the offense is still reported.
        module Next
          def check(node)
            return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)
            return if non_ruby_around_condition?(node)

            super
          end

          private

          def non_ruby_around_condition?(node)
            return false unless (conditional = trailing_conditional(node.body))
            # Ternaries have no `end` keyword (and a `Map::Ternary` loc); the cop
            # never converts them, so leave them to the original implementation.
            return false if conditional.ternary?
            return false unless node.loc.end && conditional.loc.end

            processed_source.non_ruby_between?(node.source_range.begin_pos, conditional.loc.keyword.begin_pos) ||
              processed_source.non_ruby_between?(conditional.loc.end.begin_pos, node.loc.end.begin_pos)
          end

          # @return [RuboCop::AST::IfNode, nil] the `if`/`unless` that ends the body
          def trailing_conditional(body)
            candidate =
              if body&.if_type? then body
              elsif body&.begin_type? then body.children.last
              end
            candidate if candidate&.if_type?
          end
        end
      end
    end
  end
end
