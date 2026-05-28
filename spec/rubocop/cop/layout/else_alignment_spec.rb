# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ElseAlignment, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense when else and if are in separate ERB tags' do
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

  it 'registers an offense for a misaligned else within a single ERB tag' do
    expect_offense(<<~ERB, filename)
      <%
        if x
          a
          else
          ^^^^ Align `else` with `if`.
          b
        end
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        if x
          a
        else
          b
        end
      %>
    ERB
  end
end
