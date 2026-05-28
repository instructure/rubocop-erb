# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      module Style
        # Prevents false `Style/SoleNestedConditional` offenses when a nested
        # conditional lives in a separate ERB tag and the parent's body also holds
        # non-Ruby (HTML/text) content, which extraction blanks out. Merging the
        # conditions would drop that content.
        #
        # When the only thing between the conditionals is whitespace (or they share
        # a single ERB tag, i.e. pure Ruby), the offense is still reported.
        module SoleNestedConditional
          def on_if(node)
            return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)
            return if non_ruby_between_conditionals?(node)

            super
          end

          private

          def non_ruby_between_conditionals?(node)
            # Mirror the cop's own preconditions; in particular ternaries have no
            # `end` keyword (and a different `loc`), and the cop never flags them.
            return false if node.ternary? || node.else? || node.elsif?
            return false unless (inner = node.if_branch)&.if_type?
            return false if inner.ternary? || inner.else?
            return false unless node.loc.end && inner.loc.end

            # Non-Ruby content either before the nested conditional or after it,
            # within the outer conditional's body, means merging would drop markup.
            processed_source.non_ruby_between?(node.loc.keyword.begin_pos, inner.loc.keyword.begin_pos) ||
              processed_source.non_ruby_between?(inner.loc.end.begin_pos, node.loc.end.begin_pos)
          end
        end
      end
    end
  end
end
