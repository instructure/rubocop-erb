# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DuplicateBranch, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense when branches differ only in their non-Ruby content' do
    expect_no_offenses(<<~ERB, filename)
      <% if request.query_parameters[:embedded] %>
        <h3><%= t("Access Denied") %></h3>
      <% else %>
        <h1><%= t("Access Denied") %></h1>
      <% end %>
    ERB
  end

  it 'does not register an offense for a conditional spanning multiple ERB tags' do
    expect_no_offenses(<<~ERB, filename)
      <% if a %>
        <%= foo %>
      <% else %>
        <%= foo %>
      <% end %>
    ERB
  end

  it 'registers an offense for a duplicate branch within a single ERB tag' do
    expect_offense(<<~ERB, filename)
      <%
        if a
          bar
        else
        ^^^^ Duplicate branch body detected.
          bar
        end
      %>
    ERB

    expect_no_corrections
  end
end
