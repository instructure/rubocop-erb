# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Semicolon, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense for multiple nodes on the same line' do
    expect_no_offenses(<<~ERB, filename)
      <% if true %><%= content %><% end %>
    ERB
  end

  it 'does not register an offense for a single line, multi-tag block' do
    expect_no_offenses(<<~ERB, filename)
      <% content_for(:page_title) { %><%= @page_title %><% } %>
    ERB
  end

  it 'does not register an offense for a semicolon inside a string literal' do
    expect_no_offenses(<<~ERB, filename)
      <a href="<%= url %>" style="<%= 'visibility: hidden;' unless hidden %>">
    ERB
  end

  it 'registers an offense for semicolon use inside the ERB code' do
    expect_offense(<<~ERB, filename)
      <%
        foo = 1; bar = 2
               ^ Do not use semicolons to terminate expressions.
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        foo = 1
       bar = 2
      %>
    ERB
  end
end
