# encoding: UTF-8
require_relative "./spec_helper"

RSpec.describe "Decoding" do
  let(:entities) {
    [:xhtml1, :html4, :expanded].map{ |a| HTMLEntities.new(a) }
  }

  def assert_decode(expected, input)
    entities.each do |coder|
      expect(coder.decode(input)).to eq(expected)
    end
  end

  it "decodes basic entities" do
    assert_decode '&', '&amp;'
    assert_decode '<', '&lt;'
    assert_decode '"', '&quot;'
  end

  it "decodes extended named entities" do
    assert_decode '±', '&plusmn;'
    assert_decode 'ð', '&eth;'
    assert_decode 'Œ', '&OElig;'
    assert_decode 'œ', '&oelig;'
  end

  it "decodes decimal entities" do
    assert_decode '“', '&#8220;'
    assert_decode '…', '&#8230;'
    assert_decode ' ', '&#32;'
  end

  it "decodes hexadecimal entities" do
    assert_decode '−', '&#x2212;'
    assert_decode '—', '&#x2014;'
    assert_decode '`', '&#x0060;'
    assert_decode '`', '&#x60;'
  end

  it "does not mutate string being decoded" do
    original = "&lt;&#163;"
    input = original.dup
    HTMLEntities.new.decode(input)

    expect(input).to eq(original)
  end

  it "decodes text with mix of entities" do
    # Just a random headline - I needed something with accented letters.
    assert_decode(
      'Le tabac pourrait bientôt être banni dans tous les lieux publics en France',
      'Le tabac pourrait bient&ocirc;t &#234;tre banni dans tous les lieux publics en France'
    )
    assert_decode(
      '"bientôt" & 文字',
      '&quot;bient&ocirc;t&quot; &amp; &#25991;&#x5b57;'
    )
  end

  it "decodes empty string" do
    assert_decode '', ''
  end

  it "skips unknown entity" do
    assert_decode '&bogus;', '&bogus;'
  end

  it "decodes double encoded entity once" do
    assert_decode '&amp;', '&amp;amp;'
  end

  # Faults found and patched by Moonwolf
  it "decodes full hexadecimal range" do
    (0..127).each do |codepoint|
      assert_decode [codepoint].pack('U'), "&\#x#{codepoint.to_s(16)};"
    end
  end

  # Reported by Dallas DeVries and Johan Duflost
  it "decodes named entities reported as missing in 3.0.1" do
    assert_decode  [178].pack('U'), '&sup2;'
    assert_decode [8226].pack('U'), '&bull;'
    assert_decode  [948].pack('U'), '&delta;'
  end

  # Reported by ckruse
  it "decodes only first element in masked entities" do
    input = '&amp;#3346;'
    expected = '&#3346;'
    assert_decode expected, input
  end

  it "ducktypes parameter to string before encoding" do
    obj = Object.new
    def obj.to_s; "foo"; end
    assert_decode "foo", obj
  end

end
