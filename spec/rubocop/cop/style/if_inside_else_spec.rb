# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IfInsideElse, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense when non-Ruby content precedes the nested if' do
    expect_no_offenses(<<~ERB, filename)
      <% if a %>
        <span></span>
      <% else %>
        <div></div>
        <% if b %>
          <span></span>
        <% end %>
      <% end %>
    ERB
  end

  it 'does not register an offense when non-Ruby content follows the nested if' do
    expect_no_offenses(<<~ERB, filename)
      <% if a %>
        <span></span>
      <% else %>
        <% if b %>
          <span></span>
        <% end %>
        <div></div>
      <% end %>
    ERB
  end

  it 'does not register an offense when non-Ruby content precedes the nested if in an elsif chain' do
    expect_no_offenses(<<~ERB, filename)
      <% if a %>
        <h1>a</h1>
      <% elsif b %>
        <h1>b</h1>
      <% else %>
        <img>
        <% if c %>
          <h3>c</h3>
        <% else %>
          <h1>d</h1>
        <% end %>
      <% end %>
    ERB
  end

  it 'registers an offense when only whitespace separates else and the nested if' do
    expect_offense(<<~ERB, filename)
      <% if a %>
        <span></span>
      <% else %>
        <% if b %>
           ^^ Convert `if` nested inside `else` to `elsif`.
          <span></span>
        <% end %>
      <% end %>
    ERB

    # Converting to `elsif` would span ERB tags, so the correction is discarded.
    expect_no_corrections
  end

  it 'registers an offense for an if inside else within a single ERB tag' do
    expect_offense(<<~ERB, filename)
      <%
        if a
          x
        else
          if b
          ^^ Convert `if` nested inside `else` to `elsif`.
            y
          end
        end
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        if a
          x
        elsif b
          y
        end
      %>
    ERB
  end
end
