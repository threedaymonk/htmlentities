# encoding: UTF-8
require_relative "./test_helper"

class HTMLEntities::DecodingTest < Test::Unit::TestCase

  def setup
    @entities = [:xhtml1, :html4, :expanded].map{ |a| HTMLEntities.new(a) }
  end

  def assert_decode(expected, input, options = {})
    @entities.each do |coder|
      assert_equal expected, coder.decode(input, options)
    end
  end

  def test_should_decode_basic_entities
    assert_decode '&', '&amp;'
    assert_decode '<', '&lt;'
    assert_decode '"', '&quot;'
  end

  def test_should_not_decode_excluded_basic_entities
    assert_decode '&amp;', '&amp;', exclude: ['&']
    assert_decode '&lt;', '&lt;', exclude: ['<']
    assert_decode '&quot;', '&quot;', exclude: ['"']
  end

  def test_should_decode_extended_named_entities
    assert_decode '±', '&plusmn;'
    assert_decode 'ð', '&eth;'
    assert_decode 'Œ', '&OElig;'
    assert_decode 'œ', '&oelig;'
  end

  def test_should_not_decode_excluded_extended_named_entities
    assert_decode '&plusmn;', '&plusmn;', exclude: ['±']
    assert_decode '&eth;', '&eth;', exclude: ['ð']
    assert_decode '&OElig;', '&OElig;', exclude: ['Œ']
    assert_decode '&oelig;', '&oelig;', exclude: ['œ']
  end

  def test_should_decode_decimal_entities
    assert_decode '“', '&#8220;'
    assert_decode '…', '&#8230;'
    assert_decode ' ', '&#32;'
  end

  def test_should_not_decode_excluded_decimal_entities
    assert_decode '&#8220;', '&#8220;', exclude: ['“']
    assert_decode '&#8230;', '&#8230;', exclude: ['…']
    assert_decode '&#32;', '&#32;', exclude: [' ']
  end

  def test_should_decode_hexadecimal_entities
    assert_decode '−', '&#x2212;'
    assert_decode '—', '&#x2014;'
    assert_decode '`', '&#x0060;'
    assert_decode '`', '&#x60;'
  end

  def test_should_not_decode_excluded_hexadecimal_entities
    assert_decode '&#x2212;', '&#x2212;', exclude: ['−']
    assert_decode '&#x2014;', '&#x2014;', exclude: ['—']
    assert_decode '&#x0060;', '&#x0060;', exclude: ['`']
    assert_decode '&#x60;', '&#x60;', exclude: ['`']
  end

  def test_should_not_mutate_string_being_decoded
    original = "&lt;&#163;"
    input = original.dup

    HTMLEntities.new.decode(input)
    assert_equal original, input

    HTMLEntities.new.decode(input, excluded: ['a'])
    assert_equal original, input
  end

  def test_should_decode_text_with_mix_of_entities
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

  def test_should_decode_text_with_mix_of_entities_only_not_excluded
    # Just a random headline - I needed something with accented letters.
    assert_decode(
      'Le tabac pourrait bient&ocirc;t être banni dans tous les lieux publics en France',
      'Le tabac pourrait bient&ocirc;t &#234;tre banni dans tous les lieux publics en France',
      exclude: ['ô']
    )
    assert_decode(
      '"bientôt" & &#25991;字',
      '&quot;bient&ocirc;t&quot; &amp; &#25991;&#x5b57;',
      exclude: ['文']
    )
    assert_decode(
      'Le tabac pourrait bientôt être banni dans tous les lieux publics en France',
      'Le tabac pourrait bient&ocirc;t &#234;tre banni dans tous les lieux publics en France',
      exclude: ['文']
    )
  end

  def test_should_decode_empty_string
    assert_decode '', ''
    assert_decode '', '', exclude: ['a']
  end

  def test_should_skip_unknown_entity
    assert_decode '&bogus;', '&bogus;'
    assert_decode '&bogus;', '&bogus;', exclude: ['a']
  end

  def test_should_decode_double_encoded_entity_once
    assert_decode '&amp;', '&amp;amp;'
    assert_decode '&amp;', '&amp;amp;', exclude: ['a']
  end

  # Faults found and patched by Moonwolf
  def test_should_decode_full_hexadecimal_range
    (0..127).each do |codepoint|
      assert_decode [codepoint].pack('U'), "&\#x#{codepoint.to_s(16)};"
    end
  end

  def test_should_not_decode_full_hexadecimal_range_if_excluded
    (0..127).each do |codepoint|
      assert_decode "&\#x#{codepoint.to_s(16)};", "&\#x#{codepoint.to_s(16)};", exclude: [[codepoint].pack('U')]
    end
  end

  # Reported by Dallas DeVries and Johan Duflost
  def test_should_decode_named_entities_reported_as_missing_in_3_0_1
    assert_decode  [178].pack('U'), '&sup2;'
    assert_decode [8226].pack('U'), '&bull;'
    assert_decode  [948].pack('U'), '&delta;'
  end

  def test_should_not_decode_named_entities_reported_as_missing_in_3_0_1_if_excluded
    assert_decode '&sup2;', '&sup2;', exclude: [[178].pack('U')]
    assert_decode '&bull;', '&bull;', exclude: [[8226].pack('U')]
    assert_decode '&delta;', '&delta;', exclude: [[948].pack('U')]
  end

  # Reported by ckruse
  def test_should_decode_only_first_element_in_masked_entities
    input = '&amp;#3346;'
    expected = '&#3346;'
    assert_decode expected, input
  end

  def test_should_ducktype_parameter_to_string_before_encoding
    obj = Object.new
    def obj.to_s; "foo"; end
    assert_decode "foo", obj
  end

end
