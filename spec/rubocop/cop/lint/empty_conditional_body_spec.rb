# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyConditionalBody, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense for a non-Ruby body' do
    expect_no_offenses(<<~ERB, filename)
      <% if true %>
        <p>True</p>
      <% end %>
    ERB
  end

  it 'registers an offense in plain ruby' do
    expect_offense(<<~ERB, filename)
      <%
        if true
        ^^^^^^^ Avoid `if` branches without a body.
        end
      %>
    ERB

    expect_no_corrections
  end
end
