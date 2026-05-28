# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::MissingOpeningTag, :config do
  let(:filename) { 'dummy.erb' }

  it 'registers an offense when necessary' do
    expect_offense(<<~ERB, filename)
      </html>
      ^^^^^^^ Found closing tag `</html>` at (1:2) without a matching opening tag in the same scope.
    ERB

    expect_no_corrections
  end
end
