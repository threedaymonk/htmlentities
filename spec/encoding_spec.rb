# encoding: UTF-8
require_relative "./spec_helper"

RSpec.describe "Encoding" do
  let(:entities) {
    [:xhtml1, :html4, :expanded].map{ |a| HTMLEntities.new(a) }
  }

  def assert_encode(expected, input, *args)
    entities.each do |coder|
      expect(coder.encode(input, *args)).to eq(expected)
    end
  end

  it "encodes basic entities" do
    assert_encode '&amp;',  '&', :basic
    assert_encode '&quot;', '"'
    assert_encode '&lt;',   '<', :basic
    assert_encode '&lt;',   '<'
  end

  it "encodes basic entities to decimal" do
    assert_encode '&#38;', '&', :decimal
    assert_encode '&#34;', '"', :decimal
    assert_encode '&#60;', '<', :decimal
    assert_encode '&#62;', '>', :decimal
    assert_encode '&#39;', "'", :decimal
  end

  it "encodes basic entities to hexadecimal" do
    assert_encode '&#x26;', '&', :hexadecimal
    assert_encode '&#x22;', '"', :hexadecimal
    assert_encode '&#x3c;', '<', :hexadecimal
    assert_encode '&#x3e;', '>', :hexadecimal
    assert_encode '&#x27;', "'", :hexadecimal
  end

  it "encodes extended named entities" do
    assert_encode '&plusmn;', '±', :named
    assert_encode '&eth;',    'ð', :named
    assert_encode '&OElig;',  'Œ', :named
    assert_encode '&oelig;',  'œ', :named
  end

  it "encodes decimal entities" do
    assert_encode '&#8220;', '“', :decimal
    assert_encode '&#8230;', '…', :decimal
  end

  it "encodes hexadecimal entities" do
    assert_encode '&#x2212;', '−', :hexadecimal
    assert_encode '&#x2014;', '—', :hexadecimal
  end

  it "encodes text using mix of entities" do
    assert_encode(
      '&quot;bient&ocirc;t&quot; &amp; &#x6587;&#x5b57;',
      '"bientôt" & 文字', :basic, :named, :hexadecimal
    )
    assert_encode(
      '&quot;bient&ocirc;t&quot; &amp; &#25991;&#23383;',
      '"bientôt" & 文字', :basic, :named, :decimal
    )
  end

  it "sorts commands when encoding using mix of entities" do
    assert_encode(
      '&quot;bient&ocirc;t&quot; &amp; &#x6587;&#x5b57;',
      '"bientôt" & 文字', :named, :hexadecimal, :basic
    )
    assert_encode(
      '&quot;bient&ocirc;t&quot; &amp; &#25991;&#23383;',
      '"bientôt" & 文字', :decimal, :named, :basic
    )
  end

  it "detects illegal encoding command" do
    expect {
      HTMLEntities.new.encode('foo', :bar, :baz)
    }.to raise_exception(HTMLEntities::InstructionError)
  end

  it "does not encode normal ASCII" do
    assert_encode '`', '`'
    assert_encode ' ', ' '
  end

  it "doubles encode existing entity" do
    assert_encode '&amp;amp;', '&amp;'
  end

  it "does not mutate string being encoded" do
    original = "<£"
    input = original.dup
    HTMLEntities.new.encode(input, :basic, :decimal)

    expect(input).to eq(original)
  end

  it "ducktypes parameter to string before encoding" do
    obj = Object.new
    def obj.to_s; "foo"; end
    assert_encode "foo", obj
  end
end
