# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::TrailingWhitespace, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense for a single space before an ERB closing tag' do
    expect_no_offenses(<<~ERB, filename)
      <% do_something %>
    ERB
  end

  it 'does not register an offense for multiple spaces before an ERB closing tag' do
    # handled by ERB/SpaceBeforeClosingTag instead
    expect_no_offenses(<<~ERB, filename)
      <% do_something  %>
    ERB
  end

  it 'does not register an offense for an indented ERB closing tag' do
    expect_no_offenses(<<~ERB, filename)
      <html>
        <%
          do_something
        %>
      </html>
    ERB
  end

  it 'registers an offense for trailing whitespace in the ruby code' do
    expect_offense(<<~ERB, filename)
      <%
        do_something#{' '}
                    ^ Trailing whitespace detected.
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        do_something
      %>
    ERB
  end

  it 'does not crash on trailing whitespace after a trim closing tag' do
    expect_no_offenses(<<~ERB, filename)
      <% do_something -%>#{' '}
    ERB
  end

  it 'does not register an offense for a closing tag on its own line' do
    expect_no_offenses(<<~ERB, filename)
      <%
        do_something
      %>
    ERB
  end

  it 'does not register an offense for an opening tag at the end of a line' do
    # `%><%=` extracts to trailing spaces (the blanked `<%=`), but the original
    # line ends in a tag, not whitespace.
    expect_no_offenses(<<~ERB, filename)
      <% provide :page_title do %><%=
        t(:page_title, "SIS Import")
      %>
      <% end %>
    ERB
  end
end
