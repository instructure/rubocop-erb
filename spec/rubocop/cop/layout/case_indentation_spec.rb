# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::CaseIndentation, :config do
  let(:filename) { 'dummy.erb' }

  it 'aligns a `<% when %>` tag with its `<% case %>` tag, preserving the tags' do
    expect_offense(<<~ERB, filename)
      <h1>
        <% case x %>
          <% when 'Course' %>
             ^^^^ Indent `when` as deep as `case`.
            <%= t 'a' %>
          <% when 'User' %>
             ^^^^ Indent `when` as deep as `case`.
            <%= t 'b' %>
        <% end %>
      </h1>
    ERB

    expect_correction(<<~ERB)
      <h1>
        <% case x %>
        <% when 'Course' %>
            <%= t 'a' %>
        <% when 'User' %>
            <%= t 'b' %>
        <% end %>
      </h1>
    ERB
  end

  it 'does not register an offense for an already-aligned `<% when %>`' do
    expect_no_offenses(<<~ERB, filename)
      <% case x %>
      <% when 'Course' %>
        <%= t 'a' %>
      <% end %>
    ERB
  end
end
