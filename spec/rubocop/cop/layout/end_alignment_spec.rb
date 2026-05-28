# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EndAlignment, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense when end and if are in separate ERB tags' do
    expect_no_offenses(<<~ERB, filename)
      <%
        if x
      %>
        a
      <% else %>
        b
      <% end %>
    ERB
  end

  it 'registers an offense for a misaligned end within a single ERB tag' do
    expect_offense(<<~ERB, filename)
      <%
        if x
          a
          end
          ^^^ `end` at 4, 4 is not aligned with `if` at 2, 2.
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        if x
          a
        end
      %>
    ERB
  end
end
