# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::InconsistentControlFlowScope, :config do
  let(:filename) { 'dummy.erb' }

  it 'registers an offense when necessary' do
    expect_offense(<<~ERB, filename)
      <%
        if true
          if false
      %>
      <% end %>
      <% end %>
      ^^^^^^^^^ `<% end %>` appears outside its control flow block. Keep ERB control flow statements together within the same HTML scope (tag, attribute, or content).
    ERB

    expect_no_corrections
  end
end
