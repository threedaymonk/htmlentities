#
# HTML entity decoding for Ruby
#
# Author::  Paul BATTLEY (pbattley @ gmail.com)
# Version:: 1.0
# Date::    2005-08-03
#
# == About
#
# This library extends the String class to allow decoding of HTML/XML entities
# into their corresponding UTF-8 codepoints.
#
# == Licence
#
# Copyright (c) 2005 Paul Battley
#
# Usage of the works is permitted provided that this instrument is retained
# with the works, so that any entity that uses the works is notified of this
# instrument.
#
# DISCLAIMER: THE WORKS ARE WITHOUT WARRANTY.  
#

module HTMLEntities

    #
    # MAP is a hash of all the HTML entities I could discover, as taken
    # from the w3schools page on the subject:
    # http://www.w3schools.com/html/html_entitiesref.asp
    # The format is 'entity name' => codepoint where entity name is given
    # without the surrounding ampersand and semicolon.
    #
    MAP = {
        'quot'      => 34,
        'apos'      => 39,
        'amp'       => 38,
        'lt'        => 60,
        'gt'        => 62,
        'nbsp'      => 160,
        'iexcl'     => 161,
        'curren'    => 164,
        'cent'      => 162,
        'pound'     => 163,
        'yen'       => 165,
        'brvbar'    => 166,
        'sect'      => 167,
        'uml'       => 168,
        'copy'      => 169,
        'ordf'      => 170,
        'laquo'     => 171,
        'not'       => 172,
        'shy'       => 173,
        'reg'       => 174,
        'trade'     => 8482,
        'macr'      => 175,
        'deg'       => 176,
        'plusmn'    => 177,
        'sup2'      => 178,
        'sup3'      => 179,
        'acute'     => 180,
        'micro'     => 181,
        'para'      => 182,
        'middot'    => 183,
        'cedil'     => 184,
        'sup1'      => 185,
        'ordm'      => 186,
        'raquo'     => 187,
        'frac14'    => 188,
        'frac12'    => 189,
        'frac34'    => 190,
        'iquest'    => 191,
        'times'     => 215,
        'divide'    => 247,
        'Agrave'    => 192,
        'Aacute'    => 193,
        'Acirc'     => 194,
        'Atilde'    => 195,
        'Auml'      => 196,
        'Aring'     => 197,
        'AElig'     => 198,
        'Ccedil'    => 199,
        'Egrave'    => 200,
        'Eacute'    => 201,
        'Ecirc'     => 202,
        'Euml'      => 203,
        'Igrave'    => 204,
        'Iacute'    => 205,
        'Icirc'     => 206,
        'Iuml'      => 207,
        'ETH'       => 208,
        'Ntilde'    => 209,
        'Ograve'    => 210,
        'Oacute'    => 211,
        'Ocirc'     => 212,
        'Otilde'    => 213,
        'Ouml'      => 214,
        'Oslash'    => 216,
        'Ugrave'    => 217,
        'Uacute'    => 218,
        'Ucirc'     => 219,
        'Uuml'      => 220,
        'Yacute'    => 221,
        'THORN'     => 222,
        'szlig'     => 223,
        'agrave'    => 224,
        'aacute'    => 225,
        'acirc'     => 226,
        'atilde'    => 227,
        'auml'      => 228,
        'aring'     => 229,
        'aelig'     => 230,
        'ccedil'    => 231,
        'egrave'    => 232,
        'eacute'    => 233,
        'ecirc'     => 234,
        'euml'      => 235,
        'igrave'    => 236,
        'iacute'    => 237,
        'icirc'     => 238,
        'iuml'      => 239,
        'eth'       => 240,
        'ntilde'    => 241,
        'ograve'    => 242,
        'oacute'    => 243,
        'ocirc'     => 244,
        'otilde'    => 245,
        'ouml'      => 246,
        'oslash'    => 248,
        'ugrave'    => 249,
        'uacute'    => 250,
        'ucirc'     => 251,
        'uuml'      => 252,
        'yacute'    => 253,
        'thorn'     => 254,
        'yuml'      => 255,
        'OElig'     => 338,
        'oelig'     => 339,
        'Scaron'    => 352,
        'scaron'    => 353,
        'Yuml'      => 376,
        'circ'      => 710,
        'tilde'     => 732,
        'ensp'      => 8194,
        'emsp'      => 8195,
        'thinsp'    => 8201,
        'zwnj'      => 8204,
        'zwj'       => 8205,
        'lrm'       => 8206,
        'rlm'       => 8207,
        'ndash'     => 8211,
        'mdash'     => 8212,
        'lsquo'     => 8216,
        'rsquo'     => 8217,
        'sbquo'     => 8218,
        'ldquo'     => 8220,
        'rdquo'     => 8221,
        'bdquo'     => 8222,
        'dagger'    => 8224,
        'Dagger'    => 8225,
        'hellip'    => 8230,
        'permil'    => 8240,
        'lsaquo'    => 8249,
        'rsaquo'    => 8250,
        'euro'      => 8364
    }

    MIN_LENGTH = MAP.keys.map{ |a| a.length }.min
    MAX_LENGTH = MAP.keys.map{ |a| a.length }.max
end

class String

    # Precompile the regexp
    NAMED_ENTITY_REGEXP = 
        /&([a-z]{#{HTMLEntities::MIN_LENGTH},#{HTMLEntities::MAX_LENGTH}});/i 
    
    #
    # Decode XML and HTML 4.01 entities in a string into their UTF-8
    # equivalents.  Obviously, if your string is not already in UTF-8, you'd
    # better convert it before using this method, or the output will be mixed
    # up.
    # Unknown named entities are not converted
    #
    def decode_entities
        return gsub(NAMED_ENTITY_REGEXP) { 
            HTMLEntities::MAP.has_key?($1) ? [HTMLEntities::MAP[$1]].pack('U') : $& 
        }.gsub(/&#([0-9]{2,6});/) { 
            [$1.to_i].pack('U') 
        }.gsub(/&#x([0-9a-e]{2,6});/i) { 
            [$1.to_i(16)].pack('U') 
        }
    end

end

if (__FILE__ == $0)
    require 'test/unit'

    class TestHTMLEntities < Test::Unit::TestCase
        def test_basic
            assert_equal('&', '&amp;'.decode_entities)
            assert_equal('<', '&lt;'.decode_entities)
            assert_equal('"', '&quot;'.decode_entities)
        end

        def test_extended
            assert_equal('±', '&plusmn;'.decode_entities)
            assert_equal('ð', '&eth;'.decode_entities)
            assert_equal('Œ', '&OElig;'.decode_entities)
            assert_equal('œ', '&oelig;'.decode_entities)
        end

        def test_decimal
            assert_equal('“', '&#8220;'.decode_entities)
            assert_equal('…', '&#8230;'.decode_entities)
            assert_equal(' ', '&#32;'.decode_entities)
        end

        def test_hexadecimal
            assert_equal('−', '&#x2212;'.decode_entities)
            assert_equal('—', '&#x2014;'.decode_entities)
            assert_equal('`', '&#x0060;'.decode_entities)
            assert_equal('`', '&#x60;'.decode_entities)
        end

        def test_mixed
            # Just a random headline - I needed something with accented letters.
            assert_equal('Le tabac pourrait bientôt être banni dans tous les lieux publics en France', 
                'Le tabac pourrait bient&ocirc;t &#234;tre banni dans tous les lieux publics en France'.decode_entities)
        end

        def test_edge_cases
            assert_equal('', ''.decode_entities)
            assert_equal('&bogus;', '&bogus;'.decode_entities)
        end
    end

end
