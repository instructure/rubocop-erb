# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SoleNestedConditional, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense when non-Ruby content precedes the nested conditional' do
    expect_no_offenses(<<~ERB, filename)
      <% if a %>
        <div></div>
        <% unless b %>
          <span></span>
        <% end %>
      <% end %>
    ERB
  end

  it 'does not register an offense when non-Ruby content follows the nested conditional' do
    expect_no_offenses(<<~ERB, filename)
      <% if a %>
        <% if b %>
          <span></span>
        <% end %>
        <div></div>
      <% end %>
    ERB
  end

  it 'does not register an offense (or raise) when the branch is a ternary in an output tag' do
    expect_no_offenses(<<~ERB, filename)
      <% if planner_enabled? %>
        <div style="display: <%= show? ? 'block' : 'none' %>"></div>
      <% end %>
    ERB
  end

  it 'registers an offense when only whitespace separates the conditionals' do
    expect_offense(<<~ERB, filename)
      <% if a %>
        <% if b %>
           ^^ Consider merging nested conditions into outer `if` conditions.
          <span></span>
        <% end %>
      <% end %>
    ERB

    # Merging would span ERB tags and wrap the markup, so the correction is
    # discarded.
    expect_no_corrections
  end

  it 'registers an offense for a nested conditional within a single ERB tag' do
    expect_offense(<<~ERB, filename)
      <%
        if a
          if b
          ^^ Consider merging nested conditions into outer `if` conditions.
            x
          end
        end
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        if a && b
            x
          end
      %>
    ERB
  end
end
