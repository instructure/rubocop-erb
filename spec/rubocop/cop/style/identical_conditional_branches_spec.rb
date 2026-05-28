# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IdenticalConditionalBranches, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense when branches differ only in their non-Ruby content' do
    expect_no_offenses(<<~ERB, filename)
      <% if x %>
        <h3><%= t("a") %></h3>
      <% else %>
        <h1><%= t("a") %></h1>
      <% end %>
    ERB
  end

  it 'registers an offense for identical branches within a single ERB tag' do
    expect_offense(<<~ERB, filename)
      <% if x then foo else foo end %>
                   ^^^ Move `foo` out of the conditional.
                            ^^^ Move `foo` out of the conditional.
    ERB

    expect_no_corrections
  end
end
