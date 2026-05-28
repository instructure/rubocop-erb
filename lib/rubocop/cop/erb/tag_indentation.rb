# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # Indents a tag that sits alone on its line (only whitespace before it) one
      # `IndentationWidth` deeper than the container that encloses it. A container
      # is an HTML element or an ERB block/conditional construct, so both HTML and
      # Ruby nesting add a level of indentation. Both ERB tags and HTML tags are
      # checked.
      #
      # A closing HTML tag is aligned with the line that opened its element, and
      # ERB continuation/closing constructs (`else`, `elsif`, `when`, `in`,
      # `rescue`, `ensure`, `end`) are left alone, since they align with their
      # opening construct rather than its body.
      #
      # @example
      #   # bad
      #   <% items.each do |item| %>
      #   <li>
      #   <%= item.name %>
      #   </li>
      #   <% end %>
      #
      #   # good
      #   <% items.each do |item| %>
      #     <li>
      #       <%= item.name %>
      #     </li>
      #   <% end %>
      class TagIndentation < Base
        include ERBVisitor
        include Alignment
        extend AutoCorrector

        MSG = 'Indent the tag %<expected>d spaces from its enclosing container.'
        CLOSING_MSG = 'Indent the closing tag to %<expected>d spaces to match its opening tag.'

        CONTINUATION_NODES = [
          Herb::AST::ERBElseNode,
          Herb::AST::ERBEndNode,
          Herb::AST::ERBEnsureNode,
          Herb::AST::ERBInNode,
          Herb::AST::ERBRescueNode,
          Herb::AST::ERBWhenNode
        ].freeze

        CONTAINER_NODES = [
          Herb::AST::ERBBeginNode,
          Herb::AST::ERBBlockNode,
          Herb::AST::ERBCaseMatchNode,
          Herb::AST::ERBCaseNode,
          Herb::AST::ERBElseNode,
          Herb::AST::ERBEnsureNode,
          Herb::AST::ERBForNode,
          Herb::AST::ERBIfNode,
          Herb::AST::ERBInNode,
          Herb::AST::ERBRescueNode,
          Herb::AST::ERBUnlessNode,
          Herb::AST::ERBUntilNode,
          Herb::AST::ERBWhenNode,
          Herb::AST::ERBWhileNode,
          Herb::AST::HTMLElementNode
        ].freeze

        def visit_erb_node(node)
          if (container = visitable_container(node))
            expected = line_indentation(container.location.start.line) + configured_indentation_width
            register(node.tag_opening.location.start, node.tag_opening, expected, MSG)
          end
          super
        end

        def visit_html_close_tag_node(node)
          if (element = parents[node])
            expected = line_indentation(element.location.start.line)
            register(node.location.start, node, expected, CLOSING_MSG)
          end
          super
        end

        def visit_html_open_tag_node(node)
          element = parents[node]
          if element && (container = enclosing_container(element))
            expected = line_indentation(container.location.start.line) + configured_indentation_width
            register(node.location.start, node, expected, MSG)
          end
          super
        end

        private

        def children(node)
          node.respond_to?(:child_nodes) ? node.child_nodes.compact : []
        end

        def container?(node)
          CONTAINER_NODES.any? { |klass| node.instance_of?(klass) }
        end

        def continuation?(node)
          return true if CONTINUATION_NODES.any? { |klass| node.instance_of?(klass) }

          # An `elsif` is parsed as a nested `ERBIfNode` that, unlike a freestanding
          # `if`, has no `end` tag of its own.
          node.instance_of?(Herb::AST::ERBIfNode) &&
            children(node).none? { |child| child.instance_of?(Herb::AST::ERBEndNode) }
        end

        # @return [Herb::AST::Node, nil] the nearest ancestor that opens a level of
        #   indentation (an HTML element or ERB block/conditional)
        def enclosing_container(node)
          current = parents[node]
          current = parents[current] until current.nil? || container?(current)
          current
        end

        def first_on_line?(position)
          start = processed_source.herb_position_to_buffer_pos(position)
          line = processed_source.buffer.line_range(position.line)
          processed_source.template_source[line.begin_pos...start].to_s.match?(/\A\s*\z/)
        end

        def leading_whitespace(position)
          start = processed_source.herb_position_to_buffer_pos(position)
          line = processed_source.buffer.line_range(position.line)
          Parser::Source::Range.new(processed_source.buffer, line.begin_pos, start)
        end

        # @return [Integer] the column of the first non-whitespace character on the
        #   given line, i.e. that line's own indentation. A container may begin
        #   part way along its line (e.g. `<p><a>`), so its body should indent from
        #   the line's indentation rather than the container's own column.
        def line_indentation(line_number)
          line = processed_source.buffer.line_range(line_number)
          source = processed_source.template_source[line.begin_pos...line.end_pos].to_s
          source.index(/\S/) || 0
        end

        # @return [Hash] map of each node to its parent node (by identity)
        def parents
          @parents ||= {}.compare_by_identity.tap { |map| record_parents(processed_source.erb_root, nil, map) }
        end

        def record_parents(
          node,
          parent,
          map
        )
          return unless node

          map[node] = parent
          children(node).each { |child| record_parents(child, node, map) }
        end

        def register(
          position,
          highlight,
          expected,
          message
        )
          return unless first_on_line?(position)
          return if position.column == expected

          add_offense(highlight, message: format(message, expected: expected)) do |corrector|
            corrector.replace(leading_whitespace(position), ' ' * expected)
          end
        end

        # @return [Herb::AST::Node, nil] the container an ERB tag should indent
        #   from, or nil when the tag is a continuation/closing construct or has no
        #   enclosing container
        def visitable_container(node)
          return if continuation?(node)

          enclosing_container(node)
        end
      end
    end
  end
end
