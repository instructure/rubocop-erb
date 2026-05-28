# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IfWithSemicolon, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense for single line non-Ruby body' do
    expect_no_offenses(<<~ERB, filename)
      <% if true %>True<% end %>
    ERB
  end

  it 'registers an offense in plain ruby' do
    expect_offense(<<~ERB, filename)
      <%
        if true; something; end
        ^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if true;` - use a ternary operator instead.
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        true ? something : nil
      %>
    ERB
  end
end
