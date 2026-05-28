# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::TagIndentation, :config do
  let(:filename) { 'dummy.html.erb' }

  it 'indents a tag inside a block body' do
    expect_offense(<<~ERB, filename)
      <% items.each do |item| %>
      <%= item.name %>
      ^^^ Indent the tag 2 spaces from its enclosing container.
      <% end %>
    ERB

    expect_correction(<<~ERB)
      <% items.each do |item| %>
        <%= item.name %>
      <% end %>
    ERB
  end

  it 'indents a tag inside a conditional body, including the else branch' do
    expect_offense(<<~ERB, filename)
      <% if foo %>
      <%= bar %>
      ^^^ Indent the tag 2 spaces from its enclosing container.
      <% else %>
      <%= baz %>
      ^^^ Indent the tag 2 spaces from its enclosing container.
      <% end %>
    ERB

    expect_correction(<<~ERB)
      <% if foo %>
        <%= bar %>
      <% else %>
        <%= baz %>
      <% end %>
    ERB
  end

  it 'does not indent sibling statement tags' do
    expect_no_offenses(<<~ERB, filename)
      <% a = 1 %>
      <% b = 2 %>
    ERB
  end

  it 'does not indent a new block following a closing tag' do
    expect_no_offenses(<<~ERB, filename)
      <% foo do %>
        <%= bar %>
      <% end %>
      <% baz do %>
        <%= qux %>
      <% end %>
    ERB
  end

  it 'leaves continuation and closing tags alone' do
    expect_no_offenses(<<~ERB, filename)
      <% case x %>
      <% when 1 %>
        <%= a %>
      <% else %>
        <%= b %>
      <% end %>
    ERB
  end

  it 'leaves an elsif tag aligned with its if' do
    expect_no_offenses(<<~ERB, filename)
      <% if a %>
        <%= w %>
      <% elsif b %>
        <%= x %>
      <% else %>
        <%= y %>
      <% end %>
    ERB
  end

  it 'still indents a genuinely nested if inside a block body' do
    expect_offense(<<~ERB, filename)
      <% if a %>
      <% if b %>
      ^^ Indent the tag 2 spaces from its enclosing container.
        <%= x %>
      <% end %>
      <% end %>
    ERB

    expect_correction(<<~ERB)
      <% if a %>
        <% if b %>
        <%= x %>
      <% end %>
      <% end %>
    ERB
  end

  it 'indents relative to the opening tag of the immediate block when nested' do
    expect_offense(<<~ERB, filename)
      <% if a %>
        <% items.each do |i| %>
      <%= i %>
      ^^^ Indent the tag 4 spaces from its enclosing container.
        <% end %>
      <% end %>
    ERB

    expect_correction(<<~ERB)
      <% if a %>
        <% items.each do |i| %>
          <%= i %>
        <% end %>
      <% end %>
    ERB
  end

  it 'does not register an offense for a tag with code on the same line' do
    expect_no_offenses(<<~ERB, filename)
      <% items.each do |item| %><%= item.name %>
      <% end %>
    ERB
  end

  it 'counts enclosing HTML elements as indentation levels' do
    expect_no_offenses(<<~ERB, filename)
      <% items.each do |item| %>
        <li>
          <%= item.name %>
        </li>
      <% end %>
    ERB
  end

  it 'indents relative to the line indentation when the container starts mid-line' do
    expect_no_offenses(<<~ERB, filename)
      <p><a href="<%= url %>">
        <%= label %>
      </a></p>
    ERB
  end

  it 'corrects to the line indentation, not the mid-line container column' do
    expect_offense(<<~ERB, filename)
      <p><a href="<%= url %>">
      <%= label %>
      ^^^ Indent the tag 2 spaces from its enclosing container.
      </a></p>
    ERB

    expect_correction(<<~ERB)
      <p><a href="<%= url %>">
        <%= label %>
      </a></p>
    ERB
  end

  it 'indents a tag relative to its enclosing HTML element' do
    expect_offense(<<~ERB, filename)
      <% items.each do |item| %>
        <li>
      <%= item.name %>
      ^^^ Indent the tag 4 spaces from its enclosing container.
        </li>
      <% end %>
    ERB

    expect_correction(<<~ERB)
      <% items.each do |item| %>
        <li>
          <%= item.name %>
        </li>
      <% end %>
    ERB
  end

  it 'indents an HTML open tag relative to its enclosing container' do
    expect_offense(<<~ERB, filename)
      <% if a %>
      <div></div>
      ^^^^^ Indent the tag 2 spaces from its enclosing container.
      <% end %>
    ERB

    expect_correction(<<~ERB)
      <% if a %>
        <div></div>
      <% end %>
    ERB
  end

  it 'aligns an HTML closing tag with the line that opened its element' do
    expect_offense(<<~ERB, filename)
      <% if a %>
        <div>
      </div>
      ^^^^^^ Indent the closing tag to 2 spaces to match its opening tag.
      <% end %>
    ERB

    expect_correction(<<~ERB)
      <% if a %>
        <div>
        </div>
      <% end %>
    ERB
  end

  it 'does not register an offense for correctly indented HTML tags' do
    expect_no_offenses(<<~ERB, filename)
      <% if a %>
        <div>
          <%= x %>
        </div>
      <% end %>
    ERB
  end

  it 'does not indent top-level HTML tags' do
    expect_no_offenses(<<~ERB, filename)
      <div>
        <span></span>
      </div>
    ERB
  end
end
