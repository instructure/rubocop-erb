# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::TrailingEmptyLines, :config do
  let(:filename) { 'dummy.html.erb' }

  # The offense range of trailing-blank-line offenses spans newlines, which
  # `expect_offense` cannot annotate, so assert via direct investigation.
  def investigate(source)
    cop.instance_variable_get(:@options)[:autocorrect] = true
    processed_source = parse_source(source, filename)
    offenses = _investigate(cop, processed_source)
    corrector = @last_corrector # rubocop:disable RSpec/InstanceVariable
    [offenses, corrector&.rewrite]
  end

  context 'with EnforcedStyle: final_newline' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'final_newline' }
    end

    it 'registers an offense for a missing final newline' do
      expect_offense(<<~ERB, filename, chomp: true)
        <div></div>
                   ^{} Final newline missing.
      ERB

      expect_correction("<div></div>\n")
    end

    it 'registers an offense and removes trailing blank lines' do
      offenses, corrected = investigate("<div></div>\n\n\n")

      expect(offenses.map(&:message)).to eq(['2 trailing blank lines detected.'])
      expect(corrected).to eq("<div></div>\n")
    end

    it 'does not register an offense for a single final newline' do
      expect_no_offenses("<div></div>\n", filename)
    end

    it 'measures trailing HTML correctly rather than treating it as blank' do
      expect_no_offenses(<<~ERB, filename)
        <div>
        </div>
      ERB
    end
  end

  context 'with EnforcedStyle: final_blank_line' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'final_blank_line' }
    end

    it 'requires one trailing blank line' do
      offenses, corrected = investigate("<div></div>\n")

      expect(offenses.map(&:message)).to eq(['Trailing blank line missing.'])
      expect(corrected).to eq("<div></div>\n\n")
    end
  end
end
