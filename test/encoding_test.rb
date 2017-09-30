# encoding: UTF-8
require_relative "./test_helper"

class HTMLEntities::EncodingTest < Test::Unit::TestCase

  def setup
    @entities = [:xhtml1, :html4, :expanded].map{ |a| HTMLEntities.new(a) }
  end

  def assert_encode(expected, input, *args)
    @entities.each do |coder|
      assert_equal expected, coder.encode(input, *args)
    end
  end

  def test_should_encode_basic_entities
    assert_encode '&amp;',  '&', :basic
    assert_encode '&quot;', '"'
    assert_encode '&lt;',   '<', :basic
    assert_encode '&lt;',   '<'
  end

  def test_should_encode_basic_entities_to_decimal
    assert_encode '&#38;', '&', :decimal
    assert_encode '&#34;', '"', :decimal
    assert_encode '&#60;', '<', :decimal
    assert_encode '&#62;', '>', :decimal
    assert_encode '&#39;', "'", :decimal
  end

  def test_should_encode_basic_entities_to_hexadecimal
    assert_encode '&#x26;', '&', :hexadecimal
    assert_encode '&#x22;', '"', :hexadecimal
    assert_encode '&#x3c;', '<', :hexadecimal
    assert_encode '&#x3e;', '>', :hexadecimal
    assert_encode '&#x27;', "'", :hexadecimal
  end

  def test_should_encode_extended_named_entities
    assert_encode '&plusmn;', '±', :named
    assert_encode '&eth;',    'ð', :named
    assert_encode '&OElig;',  'Œ', :named
    assert_encode '&oelig;',  'œ', :named
  end

  def test_should_encode_decimal_entities
    assert_encode '&#8220;', '“', :decimal
    assert_encode '&#8230;', '…', :decimal
  end

  def test_should_encode_hexadecimal_entities
    assert_encode '&#x2212;', '−', :hexadecimal
    assert_encode '&#x2014;', '—', :hexadecimal
  end

  def test_should_limit_encoding_to_four_byte_characters
    assert_encode '−', '−', :hexadecimal, :four_byte
    assert_encode '&#x1f32f;', '🌯', :hexadecimal, :four_byte
  end

  def test_should_encode_text_using_mix_of_entities
    assert_encode(
      '&quot;bient&ocirc;t&quot; &amp; &#x6587;&#x5b57;',
      '"bientôt" & 文字', :basic, :named, :hexadecimal
    )
    assert_encode(
      '&quot;bient&ocirc;t&quot; &amp; &#25991;&#23383;',
      '"bientôt" & 文字', :basic, :named, :decimal
    )
  end

  def test_should_sort_commands_when_encoding_using_mix_of_entities
    assert_encode(
      '&quot;bient&ocirc;t&quot; &amp; &#x6587;&#x5b57;',
      '"bientôt" & 文字', :named, :hexadecimal, :basic
    )
    assert_encode(
      '&quot;bient&ocirc;t&quot; &amp; &#25991;&#23383;',
      '"bientôt" & 文字', :decimal, :named, :basic
    )
  end

  def test_should_detect_illegal_encoding_command
    assert_raise HTMLEntities::InstructionError do
      HTMLEntities.new.encode('foo', :bar, :baz)
    end
  end

  def test_should_not_encode_normal_ASCII
    assert_encode '`', '`'
    assert_encode ' ', ' '
  end

  def test_should_double_encode_existing_entity
    assert_encode '&amp;amp;', '&amp;'
  end

  def test_should_not_mutate_string_being_encoded
    original = "<£"
    input = original.dup
    HTMLEntities.new.encode(input, :basic, :decimal)

    assert_equal original, input
  end

  def test_should_ducktype_parameter_to_string_before_encoding
    obj = Object.new
    def obj.to_s; "foo"; end
    assert_encode "foo", obj
  end
end
