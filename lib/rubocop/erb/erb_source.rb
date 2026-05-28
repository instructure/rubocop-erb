# frozen_string_literal: true

module RuboCop
  module Erb
    class ERBSource < ProcessedSource
      # Pass off Herb errors as Parser errors
      class Diagnostic < Parser::Diagnostic
        def initialize(
          message,
          location
        )
          super(:error, message, nil, location)
        end

        # Intentionally overwrite's Parser::Diagnostic#message, because our messages won't be
        # in their templates
        def message
          @reason
        end
      end

      # Herb errors that are about the Ruby/ERB itself rather than HTML structure.
      # For a non-HTML template (the text between tags is Ruby, JS, markdown, etc.)
      # every other error is spurious HTML parsing and is dropped.
      RUBY_SYNTAX_ERROR_CLASSES = [
        Herb::Errors::RubyParseError,
        Herb::Errors::UnclosedERBTagError,
        Herb::Errors::MissingERBEndTagError,
        Herb::Errors::NestedERBTagError
      ].freeze

      attr_reader :herb_parse_result, :template_source

      def initialize(
        template_source,
        ...
      )
        @template_source = template_source
        @herb_parse_result = Herb.parse(template_source)

        super(...)

        @diagnostics = herb_parse_result.errors.filter_map do |error|
          next if Cop::ERB::ERBError::NON_SYNTAX_ERROR_CLASSES.include?(error.class)
          next if suppressed_html_error?(error)

          Diagnostic.new(error.message, herb_location_to_parser_range(error.location))
        end
      end

      # @param [Integer] byte_offset offset into the (original) source in bytes
      # @return [Integer] the equivalent character offset
      def byte_to_char_offset(byte_offset)
        template_source.byteslice(0, byte_offset).length
      end

      # @param [Integer] position full position in the buffer
      # @return [Herb::AST::Node, nil] the ERB node whose tag contains the position
      def erb_node_for_pos(position)
        erb_node_offsets.bsearch do |(range, _node)|
          next -1 if position < range.begin
          next 1 if position >= range.end

          0
        end&.last
      end

      # Buffer ranges of every ERB tag (`<% … %>`), paired with their node.
      #
      # @return [Array<(Range, Herb::AST::Node)>]
      def erb_node_offsets
        @erb_node_offsets ||= [].tap { |offsets| ERBNodeOffsetVisitor.new(self, offsets).visit(erb_root) }
      end

      # @return [Herb::AST::DocumentNode]
      def erb_root
        herb_parse_result.value
      end

      # @param [Herb::Location] location
      # @return [Parser::Source::Range]
      def herb_location_to_parser_range(location)
        Parser::Source::Range.new(buffer,
                                  herb_position_to_buffer_pos(location.start),
                                  herb_position_to_buffer_pos(location.end))
      end

      # @param [Herb::Position] position
      # @return [Integer]
      def herb_position_to_buffer_pos(position)
        line_range = buffer.line_range(position.line)
        # Herb reports columns as byte offsets, but the parser buffer uses
        # character offsets; convert so multi-byte characters line up.
        char_column = line_range.source.byteslice(0, position.column).length
        line_range.begin.begin_pos + char_column
      end

      # @param [Herb::Position] position
      # @return [Parser::Source::Range] zero-width range at the position
      def herb_position_to_parser_range(position)
        pos = herb_position_to_buffer_pos(position)
        Parser::Source::Range.new(buffer, pos, pos)
      end

      # @param [Herb::Range] range
      # @return [Parser::Source::Range]
      def herb_range_to_parser_range(range)
        # Herb ranges are byte offsets into the source; the parser buffer uses
        # character offsets, so convert to keep multi-byte characters aligned.
        Parser::Source::Range.new(buffer, byte_to_char_offset(range.from), byte_to_char_offset(range.to))
      end

      # @return [Boolean] whether the file is treated as an HTML template, i.e. its
      #   name ends in `.html.erb` or it sits directly in an `html/` directory
      def html_template?
        return false unless path

        File.basename(path).end_with?('.html.erb') || File.basename(File.dirname(path)) == 'html'
      end

      # Whether there is non-whitespace, non-Ruby (HTML/text) content between the
      # ERB tag containing +from_pos+ and the (later) ERB tag containing
      # +to_pos+. Returns false when both positions are in the same tag.
      #
      # @return [Boolean]
      def non_ruby_between?(
        from_pos,
        to_pos
      )
        from_tag = erb_node_for_pos(from_pos)
        to_tag = erb_node_for_pos(to_pos)
        return false if from_tag.nil? || to_tag.nil? || from_tag.equal?(to_tag)

        gap_begin = herb_position_to_buffer_pos(from_tag.tag_closing.location.end)
        gap_end = herb_position_to_buffer_pos(to_tag.tag_opening.location.start)
        !template_source[gap_begin...gap_end].to_s.match?(/\A\s*\z/)
      end

      # @return [Boolean] whether the buffer range lies entirely within the Ruby
      #   content (between the delimiters) of a single ERB tag
      def range_within_ruby_content?(
        begin_pos,
        end_pos
      )
        return false unless (node = erb_node_for_pos(begin_pos)) && (content = node.content)

        begin_pos >= herb_position_to_buffer_pos(content.location.start) &&
          end_pos <= herb_position_to_buffer_pos(content.location.end)
      end

      # @return [Boolean] whether the buffer range begins and ends in the same ERB
      #   tag (so it does not span any non-Ruby content between tags)
      def range_within_single_erb_node?(
        begin_pos,
        end_pos
      )
        node = erb_node_for_pos(begin_pos)
        !node.nil? && node.equal?(erb_node_for_pos(end_pos - 1))
      end

      # @return [Boolean] whether the error is HTML-structure parsing noise that
      #   should be ignored because this is not an HTML template
      def suppressed_html_error?(error)
        !html_template? && RUBY_SYNTAX_ERROR_CLASSES.none? { |klass| error.is_a?(klass) }
      end

      # Convert various Herb node or range types to a Parser::Source::Range
      # Unrecognized values are passed through
      #
      # @param [#range, #location, Herb::Location, Herb::Range, Object] node_or_range
      # @return [Parser::Source::Range, Object, nil]
      def to_range(node_or_range)
        node_or_range = node_or_range.range if node_or_range.respond_to?(:range)
        if node_or_range.is_a?(Herb::AST::Node) || node_or_range.is_a?(Herb::Token)
          node_or_range = node_or_range.location
        end
        node_or_range = herb_location_to_parser_range(node_or_range) if node_or_range.is_a?(Herb::Location)
        node_or_range = herb_range_to_parser_range(node_or_range) if node_or_range.is_a?(Herb::Range)
        node_or_range = herb_position_to_parser_range(node_or_range) if node_or_range.is_a?(Herb::Position)

        node_or_range
      end

      # Collects the buffer range of every ERB tag, paired with its node.
      class ERBNodeOffsetVisitor < Herb::Visitor
        def initialize(
          source,
          offsets
        )
          @source = source
          @offsets = offsets
          super()
        end

        def visit_erb_node(node)
          @offsets << [
            Range.new(@source.herb_position_to_buffer_pos(node.tag_opening.location.start),
                      @source.herb_position_to_buffer_pos(node.tag_closing.location.end),
                      true),
            node
          ]
          super
        end
      end
      private_constant :ERBNodeOffsetVisitor
    end
  end
end
