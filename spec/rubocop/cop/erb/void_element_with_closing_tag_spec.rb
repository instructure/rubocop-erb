# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::VoidElementWithClosingTag, :config do
  let(:filename) { 'dummy.erb' }

  it 'registers an offense when necessary' do
    expect_offense(<<~ERB, filename)
      <input></input>
             ^^^^^^^^ `input` is a void element and should not be used as a closing tag. Use `<input>` or `<input />` instead of `</input>`.
    ERB

    expect_no_corrections
  end
end
