# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Resolves the rendered (final, top-level) statement of each output ERB tag
      # (`<%=`/`<%==`). An output tag renders the value of its last statement, so
      # that is the node whose value is actually used.
      #
      # The mapping is built in a single pass over the AST and memoized per
      # processed source, so repeated lookups stay cheap regardless of how many
      # output tags a template has.
      module RenderedStatement
        # @param [Herb::AST::Node] erb_node an ERB output tag
        # @return [RuboCop::AST::Node, nil] the AST node it renders
        def rendered_statement(erb_node)
          rendered_statements[erb_node]
        end

        private

        # @return [Hash{Herb::AST::Node => RuboCop::AST::Node}]
        def build_rendered_statements
          ast = processed_source.is_a?(RuboCop::Erb::ERBSource) ? processed_source.ast : nil
          furthest = {}.compare_by_identity
          content_ranges = {}.compare_by_identity
          return furthest unless ast

          ast.each_node do |candidate|
            next unless (candidate_range = candidate.source_range)
            next unless (tag = processed_source.erb_node_for_pos(candidate_range.begin_pos))
            next unless tag.tag_opening&.value&.start_with?('<%=')
            next unless (range = (content_ranges[tag] ||= output_content_range(tag)))
            next unless candidate_range.begin_pos >= range.begin && candidate_range.end_pos <= range.end

            current = furthest[tag]
            furthest[tag] = candidate if current.nil? || later_statement?(candidate_range, current.source_range)
          end

          resolve_rendered_statements(furthest)
        end

        # @return [Boolean] whether +range+ ends later than +other+, or ends at
        #   the same position but encloses it
        def later_statement?(
          range,
          other
        )
          range.end_pos > other.end_pos ||
            (range.end_pos == other.end_pos && range.begin_pos < other.begin_pos)
        end

        # @return [Range, nil] buffer range of the tag's Ruby content
        def output_content_range(tag)
          return unless (content = tag.content)

          start = processed_source.herb_position_to_buffer_pos(content.location.start)
          finish = processed_source.herb_position_to_buffer_pos(content.location.end)
          start...finish
        end

        def rendered_statements
          return @rendered_statements if @rendered_statements_source.equal?(processed_source)

          @rendered_statements_source = processed_source
          @rendered_statements = build_rendered_statements
        end

        def resolve_rendered_statements(furthest)
          furthest.each_with_object({}.compare_by_identity) do |(tag, rendered), statements|
            # A `begin` node is a statement sequence, not a rendered value; the
            # rendered value is its last statement.
            rendered = rendered.children.last while rendered&.begin_type?
            statements[tag] = rendered
          end
        end
      end
    end
  end
end
