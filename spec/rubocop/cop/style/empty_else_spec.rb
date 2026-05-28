# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyElse, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense for a non-Ruby body' do
    expect_no_offenses(<<~ERB, filename)
      <% if true %>
        <p>True</p>
      <% else %>
        <p>False</p>
      <% end %>
    ERB
  end

  it 'does not register an offense for a non-Ruby elsif body' do
    expect_no_offenses(<<~ERB, filename)
      <% if true %>
        <p>True</p>
      <% elsif false %>
        <p>False</p>
      <% end %>
    ERB
  end

  it 'does not register an offense for a non-Ruby elsif/else body' do
    expect_no_offenses(<<~ERB, filename)
      <% if true %>
        <p>True</p>
      <% elsif false %>
        <p>False</p>
      <% else %>
        <p>Neither</p>
      <% end %>
    ERB
  end

  it 'registers an offense in plain ruby' do
    expect_offense(<<~ERB, filename)
      <%
        if true
          # nothing
        else
        ^^^^ Redundant `else`-clause.
        end
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        if true
          # nothing
        end
      %>
    ERB
  end
end
