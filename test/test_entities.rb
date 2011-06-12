#!/usr/bin/env ruby

$KCODE = 'u'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib") if __FILE__ == $0
require 'test/unit'
require 'htmlentities'

class TestHTMLEntities < Test::Unit::TestCase
    def test_basic_d
        assert_equal('&', '&amp;'.decode_entities)
        assert_equal('<', '&lt;'.decode_entities)
        assert_equal('"', '&quot;'.decode_entities)
    end
        
    def test_basic_e
        assert_equal('&amp;', '&'.encode_entities(:basic))
        assert_equal('&quot;', '"'.encode_entities)
        assert_equal('&lt;', '<'.encode_entities(:basic))
        assert_equal('&lt;', '<'.encode_entities)
    end

    def test_extended_d
        assert_equal('±', '&plusmn;'.decode_entities)
        assert_equal('ð', '&eth;'.decode_entities)
        assert_equal('Œ', '&OElig;'.decode_entities)
        assert_equal('œ', '&oelig;'.decode_entities)
    end
        
    def test_extended_e
        assert_equal('&plusmn;', '±'.encode_entities(:named))
        assert_equal('&eth;', 'ð'.encode_entities(:named))
        assert_equal('&OElig;', 'Œ'.encode_entities(:named))
        assert_equal('&oelig;', 'œ'.encode_entities(:named))
    end

    def test_decimal_d
        assert_equal('“', '&#8220;'.decode_entities)
        assert_equal('…', '&#8230;'.decode_entities)
        assert_equal(' ', '&#32;'.decode_entities)
    end
        
    def test_decimal_e
        assert_equal('&#8220;', '“'.encode_entities(:decimal))
        assert_equal('&#8230;', '…'.encode_entities(:decimal))
    end

    def test_hexadecimal_d
        assert_equal('−', '&#x2212;'.decode_entities)
        assert_equal('—', '&#x2014;'.decode_entities)
        assert_equal('`', '&#x0060;'.decode_entities)
        assert_equal('`', '&#x60;'.decode_entities)
    end
        
    def test_hexadecimal_e
        assert_equal('&#x2212;', '−'.encode_entities(:hexadecimal))
        assert_equal('&#x2014;', '—'.encode_entities(:hexadecimal))
    end

    def test_mixed_d
        # Just a random headline - I needed something with accented letters.
        assert_equal('Le tabac pourrait bientôt être banni dans tous les lieux publics en France', 
            'Le tabac pourrait bient&ocirc;t &#234;tre banni dans tous les lieux publics en France'.decode_entities)
    end

    def test_mixed_e
        assert_equal('&quot;bient&ocirc;t&quot; &amp; &#x6587;&#x5b57;',
            '"bientôt" & 文字'.encode_entities(:basic, :named, :hexadecimal))
        assert_equal('&quot;bient&ocirc;t&quot; &amp; &#25991;&#23383;',
            '"bientôt" & 文字'.encode_entities(:basic, :named, :decimal))
    end
    
    def test_mixed_e_with_sort
        assert_equal('&quot;bient&ocirc;t&quot; &amp; &#x6587;&#x5b57;',
            '"bientôt" & 文字'.encode_entities(:named, :hexadecimal, :basic))
        assert_equal('&quot;bient&ocirc;t&quot; &amp; &#25991;&#23383;',
            '"bientôt" & 文字'.encode_entities(:decimal, :named, :basic))
    end

    def test_detect_illegal_command_e
        assert_raise(RuntimeError) {
            'foo'.encode_entities(:bar, :baz)
        }
    end

    def test_edge_cases_d
        assert_equal('', ''.decode_entities)
        assert_equal('&bogus;', '&bogus;'.decode_entities)
        assert_equal('&amp;', '&amp;amp;'.decode_entities)
    end

    def test_edge_cases_e
        assert_equal('`', '`'.encode_entities(:hexadecimal))
        assert_equal(' ', ' '.encode_entities(:decimal))
        assert_equal('&amp;amp;', '&amp;'.encode_entities(:basic))
        assert_equal('&amp;amp;', '&amp;'.encode_entities(:basic, :named))
    end
end

