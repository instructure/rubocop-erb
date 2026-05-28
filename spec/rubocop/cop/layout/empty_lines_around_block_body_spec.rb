# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLinesAroundBlockBody, :config do
  let(:filename) { 'dummy.html.erb' }

  it 'does not register an offense for a blank line in a block body spanning ERB tags' do
    expect_no_offenses(<<~ERB, filename)
      <% content.each do |example| %>
        <%= example %>

      <% end %>
    ERB
  end

  it 'does not register an offense for a blank template line at the start of a block body' do
    expect_no_offenses(<<~ERB, filename)
      <% content.each do |example| %>

        <%= example %>
      <% end %>
    ERB
  end

  it 'registers an offense for a blank line in a block body within a single ERB tag' do
    expect_offense(<<~ERB, filename)
      <%
        items.each do |i|
          do_x(i)

      ^{} Extra empty line detected at block body end.
        end
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        items.each do |i|
          do_x(i)
        end
      %>
    ERB
  end
end
