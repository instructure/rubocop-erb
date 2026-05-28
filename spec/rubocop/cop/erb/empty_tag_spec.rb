# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::EmptyTag, :config do
  let(:filename) { 'dummy.erb' }

  it 'registers an offense and removes an empty tag' do
    expect_offense(<<~ERB, filename)
      <div><% %></div>
           ^^^^^ Remove the empty ERB tag.
    ERB

    expect_correction(<<~ERB)
      <div></div>
    ERB
  end

  it 'registers an offense and removes an empty output tag' do
    expect_offense(<<~ERB, filename)
      <div><%= %></div>
           ^^^^^^ Remove the empty ERB tag.
    ERB

    expect_correction(<<~ERB)
      <div></div>
    ERB
  end

  it 'registers an offense and removes an empty comment tag' do
    expect_offense(<<~ERB, filename)
      <div><%# %></div>
           ^^^^^^ Remove the empty ERB tag.
    ERB

    expect_correction(<<~ERB)
      <div></div>
    ERB
  end

  it 'does not register an offense for an escape tag' do
    expect_no_offenses(<<~ERB, filename)
      <div><%% %></div>
    ERB
  end

  it 'does not register an offense for a tag with content' do
    expect_no_offenses(<<~ERB, filename)
      <div><% foo %></div>
    ERB
  end
end
