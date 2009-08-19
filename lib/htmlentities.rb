# encoding: UTF-8
require 'htmlentities/legacy'
require 'htmlentities/flavors'
require 'htmlentities/version'

#
# HTML entity encoding and decoding for Ruby
#
class HTMLEntities
  INSTRUCTIONS = [:basic, :named, :decimal, :hexadecimal]

  InstructionError = Class.new(RuntimeError)
  UnknownFlavor    = Class.new(RuntimeError)

  #
  # Create a new HTMLEntities coder for the specified flavor.
  # Available flavors are 'html4', 'expanded' and 'xhtml1' (the default).
  #
  # The only difference in functionality between html4 and xhtml1 is in the
  # handling of the apos (apostrophe) named entity, which is not defined in
  # HTML4.
  #
  # 'expanded' includes a large number of additional SGML entities drawn from
  #   ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/MISC/SGML.TXT
  # it "maps SGML character entities from various public sets (namely, ISOamsa,
  # ISOamsb, ISOamsc, ISOamsn, ISOamso, ISOamsr, ISObox, ISOcyr1, ISOcyr2,
  # ISOdia, ISOgrk1, ISOgrk2, ISOgrk3, ISOgrk4, ISOlat1, ISOlat2, ISOnum,
  # ISOpub, ISOtech, HTMLspecial, HTMLsymbol) to corresponding Unicode
  # characters." (sgml.txt).
  #
  # 'expanded' is a strict superset of the XHTML entities: every xhtml named
  # entity encodes and decodes the same under :expanded as under :xhtml1
  #
  def initialize(flavor='xhtml1')
    @flavor = flavor.to_s.downcase
    raise UnknownFlavor, "Unknown flavor #{flavor}" unless FLAVORS.include?(@flavor)
  end

  #
  # Decode entities in a string into their UTF-8
  # equivalents. The string should already be in UTF-8 encoding.
  #
  # Unknown named entities will not be converted
  #
  def decode(source)
    return source.to_s.gsub(named_entity_regexp) {
      (cp = map[$1]) ? [cp].pack('U') : $&
    }.gsub(/&#([0-9]{1,7});|&#x([0-9a-f]{1,6});/i) {
      $1 ? [$1.to_i].pack('U') : [$2.to_i(16)].pack('U')
    }
  end

  #
  # Encode codepoints into their corresponding entities.  Various operations
  # are possible, and may be specified in order:
  #
  # :basic :: Convert the five XML entities ('"<>&)
  # :named :: Convert non-ASCII characters to their named HTML 4.01 equivalent
  # :decimal :: Convert non-ASCII characters to decimal entities (e.g. &#1234;)
  # :hexadecimal :: Convert non-ASCII characters to hexadecimal entities (e.g. # &#x12ab;)
  #
  # You can specify the commands in any order, but they will be executed in
  # the order listed above to ensure that entity ampersands are not
  # clobbered and that named entities are replaced before numeric ones.
  #
  # If no instructions are specified, :basic will be used.
  #
  # Examples:
  #   encode_entities(str) - XML-safe
  #   encode_entities(str, :basic, :decimal) - XML-safe and 7-bit clean
  #   encode_entities(str, :basic, :named, :decimal) - 7-bit clean, with all
  #   non-ASCII characters replaced with their named entity where possible, and
  #   decimal equivalents otherwise.
  #
  # Note: It is the program's responsibility to ensure that the source
  # contains valid UTF-8 before calling this method.
  #
  def encode(source, *instructions)
    encoder = Encoder.new(@flavor, instructions)
    encoder.encode(source)
  end

private
  def map
    @map ||= HTMLEntities::MAPPINGS[@flavor]
  end

  def named_entity_regexp
    @named_entity_regexp ||= (
      min_length = map.keys.map{ |a| a.length }.min
      max_length = map.keys.map{ |a| a.length }.max
      ok_chars = @flavor.to_s == 'expanded' ? '(?:b\.)?[a-z][a-z0-9]' : '[a-z][a-z0-9]'
      /&(#{ok_chars}{#{min_length-1},#{max_length-1}});/i
    )
  end

  class Encoder #:nodoc:
    def initialize(flavor, instructions)
      @flavor = flavor
      instructions << :basic if (instructions.empty?)
      validate_instructions(instructions)
      build_basic_entity_encoder(instructions)
      build_extended_entity_encoder(instructions)
    end

    def encode(source)
      string = source.to_s.dup
      string.gsub!(basic_entity_regexp){ encode_basic($&) }
      string.gsub!(extended_entity_regexp){ encode_extended($&) }
      string
    end

  private
    def basic_entity_regexp
      @basic_entity_regexp ||= (
        case @flavor
        when /^html/
          /[<>"&]/
        else
          /[<>'"&]/
        end
      )
    end

    def extended_entity_regexp
      @extended_entity_regexp ||= (
        if encoding_aware?
          regexp = '[^\u{20}-\u{7E}]'
        else
          regexp = '[^\x20-\x7E]'
        end
        regexp += "|'" if @flavor == 'html4'
        Regexp.new(regexp)
      )
    end

    def validate_instructions(instructions)
      unknown_instructions = instructions - INSTRUCTIONS
      if unknown_instructions.any?
        raise InstructionError, "unknown encode_entities command(s): #{unknown_instructions.inspect}"
      end

      if (instructions.include?(:decimal) && instructions.include?(:hexadecimal))
        raise InstructionError, "hexadecimal and decimal encoding are mutually exclusive"
      end
    end

    def build_basic_entity_encoder(instructions)
      if instructions.include?(:basic) || instructions.include?(:named)
        method = :encode_named
      elsif instructions.include?(:decimal)
        method = :encode_decimal
      elsif instructions.include?(:hexadecimal)
        method = :encode_hexadecimal
      end
      instance_eval "def encode_basic(char)\n#{method}(char)\nend"
    end

    def build_extended_entity_encoder(instructions)
      definition = "def encode_extended(char)\n"
      ([:named, :decimal, :hexadecimal] & instructions).each do |encoder|
        definition << "encoded = encode_#{encoder}(char)\n"
        definition << "return encoded if encoded\n"
      end
      definition << "char\n"
      definition << "end"
      instance_eval definition
    end

    def encode_named(char)
      cp = char.unpack('U')[0]
      (e = reverse_map[cp]) && "&#{e};"
    end

    def encode_decimal(char)
      "&##{char.unpack('U')[0]};"
    end

    def encode_hexadecimal(char)
      "&#x#{char.unpack('U')[0].to_s(16)};"
    end

    def reverse_map
      @reverse_map ||= (
        skips = HTMLEntities::SKIP_DUP_ENCODINGS[@flavor]
        map = HTMLEntities::MAPPINGS[@flavor]
        uniqmap = skips ? map.reject{|ent,hx| skips.include? ent} : map
        uniqmap.invert
      )
    end

    def encoding_aware?
      "1.9".respond_to?(:encoding)
    end
  end
end
