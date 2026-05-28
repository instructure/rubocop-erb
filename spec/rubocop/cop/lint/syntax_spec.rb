# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::Syntax, :config do
  let(:filename) { 'dummy.erb' }

  let(:commissioner) { RuboCop::Cop::Commissioner.new([cop]) }
  let(:processed_source) { parse_source(source, filename) }
  let(:offenses) { commissioner.investigate(processed_source).offenses }
  let(:source) { '<% x' }

  it 'registers an offense for an ERB syntax error' do
    expect(offenses.size).to be 1
    offense = offenses.first
    expect(offense.message).to eql 'ERB tag `<%` at (1:0) is missing closing `%>`.'
    expect(offense.severity).to eq(:fatal)
  end
end
