# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::FirstLineLineBreak, :config do
  let(:filename) { 'dummy.erb' }

  it 'registers an offense when the first line of code is on the opening tag line' do
    expect_offense(<<~ERB, filename)
      <% foo(a,
         ^^^^^^ Add a line break before the first line of code in a multi-line ERB tag.
             b) %>
    ERB

    expect_correction(<<~ERB)
      <%
        foo(a,
             b) %>
    ERB
  end

  it 'registers an offense for an output tag' do
    expect_offense(<<~ERB, filename)
      <%= foo(a,
          ^^^^^^ Add a line break before the first line of code in a multi-line ERB tag.
              b) %>
    ERB

    expect_correction(<<~ERB)
      <%=
        foo(a,
              b) %>
    ERB
  end

  it 'does not register an offense when the first line of code is already on its own line' do
    expect_no_offenses(<<~ERB, filename)
      <%
        foo(a,
            b) %>
    ERB
  end

  it 'does not register an offense for a single line of code' do
    expect_no_offenses(<<~ERB, filename)
      <% foo(a, b) %>
    ERB
  end

  it 'does not register an offense for a single line of code spanning a multi-line tag' do
    expect_no_offenses(<<~ERB, filename)
      <%
        foo(a, b)
      %>
    ERB
  end
end
