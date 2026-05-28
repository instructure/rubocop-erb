# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SafeNavigation, :config do
  let(:filename) { 'dummy.html.erb' }

  it 'does not register an offense when the check and the call span ERB tags' do
    expect_no_offenses(<<~ERB, filename)
      <% if thing %><a id="module_<%= thing.id %>"></a><% end %>
    ERB
  end

  it 'registers an offense for a guarded call within a single ERB tag' do
    expect_offense(<<~ERB, filename)
      <% if thing
         ^^^^^^^^ Use safe navigation (`&.`) instead of checking if an object exists before calling the method.
           thing.id
         end %>
    ERB

    expect_correction(<<~ERB)
      <% thing&.id %>
    ERB
  end
end
