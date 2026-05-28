# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyWhen, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense when a when branch body is in a separate ERB tag' do
    expect_no_offenses(<<~ERB, filename)
      <% case type %>
      <% when "a", "b" %>
        <input/>
      <% end %>
    ERB
  end

  it 'registers an offense for a genuinely empty when within a single ERB tag' do
    expect_offense(<<~ERB, filename)
      <%
        case type
        when "a"
        ^^^^^^^^ Avoid `when` branches without a body.
        end
      %>
    ERB

    expect_no_corrections
  end
end
