# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::IndentationConsistency, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense for random ERB tags' do
    expect_no_offenses(<<~ERB, filename)
      <%= things.each do |thing| %>
        <%= thing.name %>
        <span>
          <%= other_thing.name %>
        </span>
      <% end %>
    ERB
  end

  it 'does not register an offense for indentation that differs from code in a neighbouring tag' do
    expect_no_offenses(<<~ERB, filename)
      <% define_content :link do %>
        <%= foo %>
      <% end %>

      <%
        bar = 1
        baz = 2
      %>
    ERB
  end

  it 'registers an offense in plain ruby' do
    expect_offense(<<~ERB, filename)
      <%
        things.each do |thing|
          puts thing.name
            puts other_thing.name
            ^^^^^^^^^^^^^^^^^^^^^ Inconsistent indentation detected.
        end
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        things.each do |thing|
          puts thing.name
          puts other_thing.name
        end
      %>
    ERB
  end
end
