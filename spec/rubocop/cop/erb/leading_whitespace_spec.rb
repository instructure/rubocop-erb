# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::LeadingWhitespace, :config do
  let(:filename) { 'dummy.html.erb' }

  it 'registers an offense for a node starting with two spaces' do
    expect_offense(<<~ERB, filename)
      <%  do_something %>
        ^^ Leading whitespace detected.
    ERB

    expect_correction(<<~ERB)
      <% do_something %>
    ERB
  end

  it 'registers an offense for a node starting with many spaces' do
    expect_offense(<<~ERB, filename)
      <%    do_something %>
        ^^^^ Leading whitespace detected.
    ERB

    expect_correction(<<~ERB)
      <% do_something %>
    ERB
  end

  it 'does not register an offense for a opening tag on its own line' do
    expect_no_offenses(<<~ERB, filename)
      <%
        do_something
      %>
    ERB
  end

  it 'does not register an offense for a line starting with a single space' do
    expect_no_offenses(<<~ERB, filename)
      <% do_something %>
    ERB
  end
end
