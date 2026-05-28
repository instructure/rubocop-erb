# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NegatedIf, :config do
  let(:filename) { 'dummy.erb' }

  it 'corrects a negated if without clobbering the surrounding markup' do
    expect_offense(<<~ERB, filename)
      <% if !@can_view %>
         ^^^^^^^^^^^^^^^^ Favor `unless` over `if` for negative conditions.
        <div class="x"></div> <%# comment %>
      <% end %>
    ERB

    expect_correction(<<~ERB)
      <% unless @can_view %>
        <div class="x"></div> <%# comment %>
      <% end %>
    ERB
  end

  it 'corrects accurately when a multi-byte character precedes the negated if' do
    expect_offense(<<~ERB, filename)
      <span>🔒</span>
      <% if !@can_view %>
         ^^^^^^^^^^^^^^^^ Favor `unless` over `if` for negative conditions.
        <div></div>
      <% end %>
    ERB

    expect_correction(<<~ERB)
      <span>🔒</span>
      <% unless @can_view %>
        <div></div>
      <% end %>
    ERB
  end
end
