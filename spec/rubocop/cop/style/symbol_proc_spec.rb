# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SymbolProc, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense for a block whose body spans ERB tags' do
    expect_no_offenses(<<~ERB, filename)
      <% headers.each do |header| %>
        <th><%= header.first %></th>
      <% end %>
    ERB
  end

  it 'registers an offense for a block contained within a single ERB tag' do
    expect_offense(<<~ERB, filename)
      <% headers.each { |header| header.first } %>
                      ^^^^^^^^^^^^^^^^^^^^^^^^^ Pass `&:first` as an argument to `each` instead of a block.
    ERB

    expect_correction(<<~ERB)
      <% headers.each(&:first) %>
    ERB
  end
end
