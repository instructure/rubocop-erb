# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::OutputSafety, :config do
  let(:filename) { 'dummy.html.erb' }

  context 'when Rails/OutputSafety is enabled' do
    let(:config) do
      RuboCop::Config.new(
        { 'ERB/OutputSafety' => { 'Enabled' => true }, 'Rails/OutputSafety' => { 'Enabled' => true } },
        'dummy.yml'
      )
    end

    it 'registers an offense for a raw output tag' do
      expect_offense(<<~ERB, filename)
        <div><%== user_input %></div>
             ^^^^ The raw output tag `<%==` bypasses HTML escaping and may be a security risk.
      ERB
    end

    it 'does not register an offense for a normal output tag' do
      expect_no_offenses(<<~ERB, filename)
        <div><%= user_input %></div>
      ERB
    end
  end

  context 'when Rails/OutputSafety is disabled' do
    let(:config) do
      RuboCop::Config.new(
        { 'ERB/OutputSafety' => { 'Enabled' => true }, 'Rails/OutputSafety' => { 'Enabled' => false } },
        'dummy.yml'
      )
    end

    it 'does not register an offense for a raw output tag' do
      expect_no_offenses(<<~ERB, filename)
        <div><%== user_input %></div>
      ERB
    end
  end
end
