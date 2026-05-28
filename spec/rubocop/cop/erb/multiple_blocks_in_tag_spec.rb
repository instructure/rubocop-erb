# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::MultipleBlocksInTag, :config do
  let(:filename) { 'dummy.erb' }

  it 'registers an offense when necessary' do
    expect_offense(<<~ERB, filename)
      <%
      ^^ Multiple unclosed control flow blocks in a single ERB tag. Split each block into its own ERB tag, or close all blocks within the same tag.
        if true
          if false
      %>
      <% end %>
      <% end %>
    ERB

    expect_no_corrections
  end
end
