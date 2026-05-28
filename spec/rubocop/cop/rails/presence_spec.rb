# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::Presence, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense when the conditional spans ERB tags' do
    expect_no_offenses(<<~ERB, filename)
      <% if content(:footer_link).present? %>
        <%= content(:footer_link) %> &nbsp;|&nbsp;
      <% end %>
    ERB
  end

  it 'registers an offense within a single ERB tag' do
    expect_offense(<<~ERB, filename)
      <% if foo.present? then foo end %>
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `foo.presence` instead of `if foo.present? then foo end`.
    ERB

    expect_correction(<<~ERB)
      <% foo.presence %>
    ERB
  end
end
