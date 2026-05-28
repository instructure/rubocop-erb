# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantCondition, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense when the condition and body span ERB tags' do
    expect_no_offenses(<<~ERB, filename)
      <% if thing %> (<%= thing %>)<% end %>
    ERB
  end

  it 'registers an offense for a redundant condition within a single ERB tag' do
    expect_offense(<<~ERB, filename)
      <% if thing; thing; end %>
         ^^^^^^^^^^^^^^^^^^^^ This condition is not needed.
    ERB

    expect_correction(<<~ERB)
      <% thing %>
    ERB
  end
end
