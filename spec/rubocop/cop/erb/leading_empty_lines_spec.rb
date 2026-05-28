# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::LeadingEmptyLines, :config do
  let(:filename) { 'dummy.html.erb' }

  it 'registers an offense and removes a leading blank line' do
    expect_offense(<<~ERB, filename)

      <div></div>
      ^ Unnecessary blank line at the beginning of the source.
    ERB

    expect_correction(<<~ERB)
      <div></div>
    ERB
  end

  it 'removes multiple leading blank lines' do
    expect_offense(<<~ERB, filename)


      <div></div>
      ^ Unnecessary blank line at the beginning of the source.
    ERB

    expect_correction(<<~ERB)
      <div></div>
    ERB
  end

  it 'does not register an offense when the file starts with content' do
    expect_no_offenses(<<~ERB, filename)
      <div></div>
    ERB
  end

  it 'recognizes leading HTML as content rather than blank' do
    expect_no_offenses(<<~ERB, filename)
      <div>
        <%= foo %>
      </div>
    ERB
  end
end
