# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::Void, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense for a literal in an output tag' do
    expect_no_offenses(<<~ERB, filename)
      <%= "selected" %>
      <% do_something %>
    ERB
  end

  it 'does not register an offense for a literal in an output tag before another tag on the same line' do
    expect_no_offenses(<<~ERB, filename)
      <%= "selected" %><% do_something %>
    ERB
  end

  it 'does not register an offense for a modifier-if output expression followed by another tag' do
    expect_no_offenses(<<~ERB, filename)
      <%= "selected" if @account == account %>
      <%= other %>
    ERB
  end

  it 'does not register an offense for an interpolated string in an output tag' do
    expect_no_offenses(<<~'ERB', filename)
      <h3><%= "#{status.titleize} accounts" %></h3>
    ERB
  end

  it 'does not register an offense for an interpolated string in an output tag followed by another tag' do
    expect_no_offenses(<<~'ERB', filename)
      <h3><%= "#{status.titleize} accounts" %></h3>
      <%= other %>
    ERB
  end

  it 'does not register an offense when an output tag renders a branch of an if spanning tags' do
    expect_no_offenses(<<~'ERB', filename)
      <% @statuses.each do |status| %>
        <% if @statuses.many? %>
          <h3><%= "#{status.titleize} accounts" %></h3>
        <% end %>
        <% current_letter = nil %>
        <%= current_letter %>
      <% end %>
    ERB
  end

  it 'registers an offense for a void statement preceding the rendered expression in an output tag' do
    expect_offense(<<~ERB, filename)
      <%= "void"; "selected" %>
          ^^^^^^ Literal `"void"` used in void context.
    ERB

    # Removing the literal would reach across into the blanked-out closing tag,
    # so the correction is discarded.
    expect_no_corrections
  end

  it 'registers an offense for a literal used in void context in a non-output tag' do
    expect_offense(<<~ERB, filename)
      <%
        "selected"
        ^^^^^^^^^^ Literal `"selected"` used in void context.
        do_something
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        do_something
      %>
    ERB
  end
end
