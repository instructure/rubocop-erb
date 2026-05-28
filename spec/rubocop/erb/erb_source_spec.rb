# frozen_string_literal: true

RSpec.describe RuboCop::Erb::ERBSource do
  subject(:erb_source) do
    processed_source = RuboCop::ProcessedSource.new(source, 3.1, filename)
    RuboCop::Erb::RubyExtractor.call(processed_source).first[:processed_source]
  end

  let(:filename) { 'dummy.html.erb' }

  describe 'HTML-structure parse errors' do
    # `<http://…>` looks like a malformed HTML tag to Herb.
    let(:source) { "# see <http://example.com/>\n" }

    context 'when the template is not an HTML template' do
      let(:filename) { 'scope_mapper_template.erb' }

      it 'ignores the spurious HTML error' do
        expect(erb_source.diagnostics).to be_empty
        expect(erb_source).to be_valid_syntax
      end
    end

    context 'when the file ends in .html.erb' do
      let(:filename) { 'page.html.erb' }

      it 'reports the HTML error' do
        expect(erb_source.diagnostics).not_to be_empty
      end
    end

    context 'when the file sits directly in an html/ directory' do
      let(:filename) { 'app/views/html/page.erb' }

      it 'reports the HTML error' do
        expect(erb_source.diagnostics).not_to be_empty
      end
    end

    context 'when a non-HTML template has a real Ruby syntax error' do
      let(:filename) { 'codegen.erb' }
      let(:source) { "<% def %>\n" }

      it 'still reports it' do
        expect(erb_source).not_to be_valid_syntax
      end
    end
  end

  describe '#herb_position_to_buffer_pos' do
    let(:source) { 'café<%= x %>' }

    it 'returns a character offset, accounting for multi-byte characters in the line' do
      _range, node = erb_source.erb_node_offsets.first

      # `<%=` begins after the 4-character (5-byte) "café"; Herb reports a byte
      # column, so a naive conversion would land at 5.
      expect(erb_source.herb_position_to_buffer_pos(node.tag_opening.location.start))
        .to eq(source.index('<%='))
    end
  end

  describe '#range_within_ruby_content?' do
    let(:source) { '<%= foo %>' }

    it 'is true for a range entirely inside the tag content' do
      start = source.index('foo')
      expect(erb_source.range_within_ruby_content?(start, start + 3)).to be(true)
    end

    it 'is false for a range that covers the opening delimiter' do
      expect(erb_source.range_within_ruby_content?(0, 3)).to be(false)
    end
  end

  describe '#non_ruby_between?' do
    context 'with non-Ruby content between two tags' do
      let(:source) { '<% a %>X<% b %>' }

      it 'is true' do
        expect(erb_source.non_ruby_between?(source.index('a'), source.index('b'))).to be(true)
      end
    end

    context 'with only whitespace between two tags' do
      let(:source) { '<% a %>  <% b %>' }

      it 'is false' do
        expect(erb_source.non_ruby_between?(source.index('a'), source.index('b'))).to be(false)
      end
    end

    context 'with both positions in the same tag' do
      let(:source) { '<% abc %>' }

      it 'is false' do
        expect(erb_source.non_ruby_between?(source.index('a'), source.index('c'))).to be(false)
      end
    end
  end
end
