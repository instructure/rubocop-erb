# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::StrayClosingTag, :config do
  let(:filename) { 'dummy.erb' }

  it 'registers an offense when necessary' do
    expect_offense(<<~ERB, filename)
      %>
      ^^ Stray `%>` found at (1:0). This closing delimiter is not part of an ERB tag and will be treated as plain text. If you want a literal `%>`, use the HTML entities `&percnt;&gt;` instead.
    ERB

    expect_no_corrections
  end
end
