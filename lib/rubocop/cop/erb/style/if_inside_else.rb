# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      module Style
        # Prevents false `Style/IfInsideElse` offenses when the `if` nested in an
        # `else` lives in a separate ERB tag and the `else` branch also holds
        # non-Ruby (HTML/text) content, which extraction blanks out. Converting it
        # to `elsif` would drop that content.
        #
        # When the only thing between the `else` and the nested `if` is whitespace
        # (or they share a single ERB tag, i.e. pure Ruby), the offense is still
        # reported.
        module IfInsideElse
          def on_if(node)
            return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)
            return if non_ruby_in_else_branch?(node)

            super
          end

          private

          # @return [Parser::Source::Range, nil] the `end` keyword closing +node+'s
          #   if/elsif chain
          def chain_end(node)
            node = node.parent while node.parent&.if_type? && node.parent.else_branch.equal?(node)
            node.loc.end
          end

          def non_ruby_in_else_branch?(node)
            return false if node.ternary? || node.unless?
            return false unless (inner = node.else_branch)&.if_type? && inner.if?
            return false unless node.loc.else && inner.loc.end

            # Non-Ruby content either before the nested `if` or after it, within
            # the `else` branch, means converting to `elsif` would drop markup.
            return true if processed_source.non_ruby_between?(node.loc.else.begin_pos, inner.loc.keyword.begin_pos)

            # An `elsif` shares the chain's `end`, so walk up to find it.
            (end_loc = chain_end(node)) &&
              processed_source.non_ruby_between?(inner.loc.end.begin_pos, end_loc.begin_pos)
          end
        end
      end
    end
  end
end
