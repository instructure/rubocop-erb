# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::BlockAlignment, :config do
  let(:filename) { 'dummy.html.erb' }

  it 'does not register an offense for a multi-tag block with the end aligned to the start of the block' do
    expect_no_offenses(<<~ERB, filename)
      <% things.each do |thing| %>
        <%= thing.name %>
      <% end %>
    ERB
  end

  it 'registers an offense in for a misaligned multi-tag block' do
    expect_offense(<<~ERB, filename)
      <% things.each do |thing| %>
        <%= thing.name %>
       <% end %>
       ^^ <% end %> is not aligned with <% at (1:0).
    ERB

    expect_correction(<<~ERB)
      <% things.each do |thing| %>
        <%= thing.name %>
      <% end %>
    ERB
  end

  it 'registers an offense and corrects an end indented less than the block opening' do
    expect_offense(<<~ERB, filename)
      <div>
        <% things.each do |thing| %>
          <%= thing.name %>
      <% end %>
      ^^ <% end %> is not aligned with <% at (2:2).
      </div>
    ERB

    expect_correction(<<~ERB)
      <div>
        <% things.each do |thing| %>
          <%= thing.name %>
        <% end %>
      </div>
    ERB
  end

  it 'does not autocorrect when content shares the closing tag line' do
    expect_offense(<<~ERB, filename)
      <% @content_for_head&.each do |string| %>
        <%= string %><% end %>
                     ^^ <% end %> is not aligned with <% at (1:0).
    ERB

    # Dedenting would delete the `<%= string %>` before the tag, so skip it.
    expect_no_corrections
  end

  it 'does not register an offense for a block opened and closed on one line' do
    expect_no_offenses(<<~ERB, filename)
      <% items.each do %><% end %>
    ERB
  end
end
