$: << File.dirname(__FILE__) + '/../lib/'
require 'htmlentities'
require 'test/unit'

$KCODE = 'u'

class TestHTMLEntities < Test::Unit::TestCase
  
  def test_basic_decoding
    assert_decode('&', '&amp;')
    assert_decode('<', '&lt;')
    assert_decode('"', '&quot;')
  end
      
  def test_basic_encoding
    assert_encode('&amp;', '&', :basic)
    assert_encode('&quot;', '"')
    assert_encode('&lt;', '<', :basic)
    assert_encode('&lt;', '<')
  end

  def test_extended_decoding
    assert_decode('±', '&plusmn;')
    assert_decode('ð', '&eth;')
    assert_decode('Œ', '&OElig;')
    assert_decode('œ', '&oelig;')
  end
      
  def test_extended_encoding
    assert_encode('&plusmn;', '±', :named)
    assert_encode('&eth;', 'ð', :named)
    assert_encode('&OElig;', 'Œ', :named)
    assert_encode('&oelig;', 'œ', :named)
  end

  def test_decimal_decoding
    assert_decode('“', '&#8220;')
    assert_decode('…', '&#8230;')
    assert_decode(' ', '&#32;')
  end
      
  def test_decimal_encoding
    assert_encode('&#8220;', '“', :decimal)
    assert_encode('&#8230;', '…', :decimal)
  end

  def test_hexadecimal_decoding
    assert_decode('−', '&#x2212;')
    assert_decode('—', '&#x2014;')
    assert_decode('`', '&#x0060;')
    assert_decode('`', '&#x60;')
  end
      
  def test_hexadecimal_encoding
    assert_encode('&#x2212;', '−', :hexadecimal)
    assert_encode('&#x2014;', '—', :hexadecimal)
  end

  def test_mixed_decoding
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

  def test_mixed_encoding
    assert_encode(
      '&quot;bient&ocirc;t&quot; &amp; &#x6587;&#x5b57;',
      '"bientôt" & 文字', :basic, :named, :hexadecimal
    )
    assert_encode(
      '&quot;bient&ocirc;t&quot; &amp; &#25991;&#23383;',
      '"bientôt" & 文字', :basic, :named, :decimal
    )
  end
  
  def test_mixed_encoding_with_sort
    assert_encode(
      '&quot;bient&ocirc;t&quot; &amp; &#x6587;&#x5b57;',
      '"bientôt" & 文字', :named, :hexadecimal, :basic
    )
    assert_encode(
      '&quot;bient&ocirc;t&quot; &amp; &#25991;&#23383;',
      '"bientôt" & 文字', :decimal, :named, :basic
    )
  end

  def test_detect_illegal_encoding_command
    assert_raise(HTMLEntities::InstructionError) {
      HTMLEntities.encode_entities('foo', :bar, :baz)
    }
  end

  def test_edge_case_decoding
    assert_decode('', '')
    assert_decode('&bogus;', '&bogus;')
    assert_decode('&amp;', '&amp;amp;')
  end

  def test_edge_case_encoding
    assert_encode('`', '`')
    assert_encode(' ', ' ')
    assert_encode('&amp;amp;', '&amp;')
    assert_encode('&amp;amp;', '&amp;')
  end

  # Faults found and patched by Moonwolf
  def test_moonwolf_decoding
    assert_decode("\x2", '&#2;')
    assert_decode("\xf", '&#xf;')
  end
  
  private

  def assert_decode(expected, input)
    assert_equal(expected, HTMLEntities.decode_entities(input))
  end
  
  def assert_encode(expected, input, *args)
    assert_equal(expected, HTMLEntities.encode_entities(input, *args))
  end

end

