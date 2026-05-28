# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Next, :config do
  let(:filename) { 'dummy.erb' }
  let(:cop_config) do
    {
      'EnforcedStyle' => 'skip_modifier_ifs',
      'MinBodyLength' => 1
    }
  end

  it 'does not flag when non-Ruby content follows the conditional within the loop' do
    # Rewriting to `next` would drop the `more stuff` markup after the `<% end %>`.
    expect_no_offenses(<<~ERB, filename)
      <% loop do %>
        <% if cond %>
          <%= do_x %>
        <% end %>
        more stuff
      <% end %>
    ERB
  end

  it 'does not flag when non-Ruby content precedes the conditional within the loop' do
    expect_no_offenses(<<~ERB, filename)
      <% loop do %>
        leading stuff
        <% if cond %>
          <%= do_x %>
        <% end %>
      <% end %>
    ERB
  end

  it 'does not flag a conditional nested directly across tags with trailing markup' do
    expect_no_offenses(<<~ERB, filename)
      <% things.each do %><% if true %>content<% end %>non-ruby<% end %>
    ERB
  end

  it 'does not crash on a ternary as the loop body across tags' do
    expect_no_offenses(<<~ERB, filename)
      <% items.each do |i| %>
        <%= i.admin? ? a : b %>
      <% end %>
    ERB
  end

  it 'flags and autocorrects a conditional contained within a single ERB tag' do
    expect_offense(<<~ERB, filename)
      <%
        loop do
          if cond
          ^^^^^^^ Use `next` to skip iteration.
            do_x
          end
        end
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        loop do
          next unless cond
          do_x
        end
      %>
    ERB
  end
end
