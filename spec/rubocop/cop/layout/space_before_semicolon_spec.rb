# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceBeforeSemicolon, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense for ERB tags in one line' do
    expect_no_offenses(<<~ERB, filename)
      <% if true %><%= something %><% end %>
    ERB
  end

  it 'does not register an offense for a missing space before the closing tag' do
    # handled by ERB/SpaceBeforeClosingTag instead
    expect_no_offenses(<<~ERB, filename)
      <td><%= something%></td>
    ERB
  end

  it 'does not register an offense for extra spaces before the closing tag' do
    # handled by ERB/SpaceBeforeClosingTag instead
    expect_no_offenses(<<~ERB, filename)
      <%= something  %>
    ERB
  end

  it 'does not register an offense for a tag containing a multi-byte character' do
    expect_no_offenses(<<~ERB, filename)
      <%= t("a’s") %>
    ERB
  end

  it 'registers an offense in plain ruby' do
    expect_offense(<<~ERB, filename)
      <%
        if true ; something; end
               ^ Space found before semicolon.
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        if true; something; end
      %>
    ERB
  end
end
