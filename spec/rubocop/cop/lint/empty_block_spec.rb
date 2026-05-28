# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyBlock, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense for ERB tags in one line' do
    expect_no_offenses(<<~ERB, filename)
      <% 5.times { %>bullet<% } %>
    ERB
  end

  it 'registers an offense in plain ruby' do
    expect_offense(<<~ERB, filename)
      <%
        5.times {}
        ^^^^^^^^^^ Empty block detected.
      %>
    ERB

    expect_no_corrections
  end
end
