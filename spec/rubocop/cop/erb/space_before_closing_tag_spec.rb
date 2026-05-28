# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::SpaceBeforeClosingTag, :config do
  let(:filename) { 'dummy.erb' }

  it 'registers an offense for no space before regular closing tag' do
    expect_offense(<<~ERB, filename)
      <% do_something%>
                     ^^ Add a space before the closing ERB tag.
    ERB

    expect_correction(<<~ERB)
      <% do_something %>
    ERB
  end

  it 'does not register an offense for a properly spaced tag' do
    expect_no_offenses(<<~ERB, filename)
      <% do_something %>
    ERB
  end

  it 'registers an offense for two spaces before a closing tag' do
    expect_offense(<<~ERB, filename)
      <% do_something  %>
                      ^ Use a single space before the closing ERB tag.
    ERB

    expect_correction(<<~ERB)
      <% do_something %>
    ERB
  end

  it 'registers an offense for many spaces before a closing tag' do
    expect_offense(<<~ERB, filename)
      <% do_something    %>
                      ^^^ Use a single space before the closing ERB tag.
    ERB

    expect_correction(<<~ERB)
      <% do_something %>
    ERB
  end

  it 'does not register an offense for a multi-line tag' do
    expect_no_offenses(<<~ERB, filename)
      <%
        do_something
      %>
    ERB
  end

  it 'does not register an offense for a mis-aligned multi-line tag' do
    expect_no_offenses(<<~ERB, filename)
      <%
        do_something
       %>
    ERB
  end
end
