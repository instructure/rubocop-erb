# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::SpaceAfterOpeningTag, :config do
  let(:filename) { 'dummy.erb' }

  it 'corrects accurately when a multi-byte character precedes the tag' do
    expect_offense(<<~ERB, filename)
      <span>🔒</span>
      <%do_something %>
      ^^ Add a space after the opening ERB tag.
    ERB

    expect_correction(<<~ERB)
      <span>🔒</span>
      <% do_something %>
    ERB
  end

  it 'registers an offense for no space after regular opening tag' do
    expect_offense(<<~ERB, filename)
      <%do_something %>
      ^^ Add a space after the opening ERB tag.
    ERB

    expect_correction(<<~ERB)
      <% do_something %>
    ERB
  end

  it 'registers an an offense for no space after opening output tag' do
    expect_offense(<<~ERB, filename)
      <%=do_something %>
      ^^^ Add a space after the opening ERB tag.
    ERB

    expect_correction(<<~ERB)
      <%= do_something %>
    ERB
  end

  it 'registers an offense for no space after opening comment tag' do
    expect_offense(<<~ERB, filename)
      <%#do_something %>
      ^^^ Add a space after the opening ERB tag.
    ERB

    expect_correction(<<~ERB)
      <%# do_something %>
    ERB
  end

  it 'does not register an offense for a properly spaced tag' do
    expect_no_offenses(<<~ERB, filename)
      <% do_something %>
    ERB
  end

  it 'does not register an offense for a properly spaced output tag' do
    expect_no_offenses(<<~ERB, filename)
      <%= do_something %>
    ERB
  end

  it 'does not register an offense for a properly spaced comment tag' do
    expect_no_offenses(<<~ERB, filename)
      <%# do_something %>
    ERB
  end

  it 'does not register an offense for a multi-line tag' do
    expect_no_offenses(<<~ERB, filename)
      <%
        do_something
      %>
    ERB
  end
end
