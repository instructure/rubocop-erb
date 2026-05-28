# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::BlockAlignment, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense for a multi-tag block with the end aligned to the start of the block' do
    expect_no_offenses(<<~ERB, filename)
      <%= things.each do |thing| %>
        <%= thing.name %>
      <% end %>
    ERB
  end

  it 'registers an offense in plain ruby' do
    expect_offense(<<~ERB, filename)
      <%
        things.each do |thing|
          puts thing.name
         end
         ^^^ `end` at 4, 3 is not aligned with `things.each do |thing|` at 2, 2.
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        things.each do |thing|
          puts thing.name
        end
      %>
    ERB
  end
end
