# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::OmittedClosingTag, :config do
  let(:filename) { 'dummy.erb' }

  it 'registers an offense when necessary' do
    expect_offense(<<~ERB, filename)
      <html>
        <p>
        ^^^ Element `<p>` at (2:3) has its closing tag omitted. While valid HTML, consider adding an explicit `</p>` closing tag at (3:0) for clarity.
      </html>
    ERB

    expect_no_corrections
  end
end
