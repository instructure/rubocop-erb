# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::MissingClosingTag, :config do
  let(:filename) { 'dummy.erb' }

  it 'registers an offense when necessary' do
    expect_offense(<<~ERB, filename)
      <html>
      ^^^^^^ Opening tag `<html>` at (1:1) doesn't have a matching closing tag `</html>` in the same scope.
    ERB

    expect_no_corrections
  end
end
