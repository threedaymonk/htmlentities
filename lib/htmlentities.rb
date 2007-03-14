require 'htmlentities/legacy'

#
# HTML entity encoding and decoding for Ruby
#

class HTMLEntities

  VERSION = '4.0.0'
  FLAVORS = %w[html4 xhtml1]

  class InstructionError < RuntimeError
  end
  class UnknownFlavor < RuntimeError
  end

  UTF8_NON_ASCII_REGEXP = /[\x00-\x1f]|[\xc0-\xfd][\x80-\xbf]+/
  ENCODE_ENTITIES_COMMAND_ORDER = {
    :basic => 0,
    :named => 1,
    :decimal => 2,
    :hexadecimal => 3
  }
  
  #
  # Create a new HTMLEntities coder for the specified flavor.
  # Available flavors are 'html4' and 'xhtml1' (the default).
  # The only difference in functionality between the two is in the handling of the apos 
  # (apostrophe) named entity, which is not defined in HTML4.
  #
  def initialize(flavor='xhtml1')
    @flavor = flavor.to_s.downcase
    raise UnknownFlavor, "Unknown flavor #{flavor}" unless FLAVORS.include?(@flavor)
  end

  #
  # Decode entities in a string into their UTF-8
  # equivalents.  Obviously, if your string is not already in UTF-8, you'd
  # better convert it before using this method, or the output will be mixed
  # up.
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
    string = source.to_s
    output = nil
    if (instructions.empty?)
      instructions = [:basic]
    else
      instructions = instructions.sort_by { |instruction|
        ENCODE_ENTITIES_COMMAND_ORDER[instruction] ||
        (raise InstructionError, "unknown encode_entities command `#{instruction.inspect}'")
      }
    end
    instructions.each do |instruction|
      case instruction
      when :basic
        # Handled as basic ASCII
        output = (output || string).gsub(basic_entity_regexp) {
          # It's safe to use the simpler [0] here because we know
          # that the basic entities are ASCII.
          '&' << reverse_map[$&[0]] << ';'
        }
      when :named
        # Test everything except printable ASCII
        output = (output || string).gsub(UTF8_NON_ASCII_REGEXP) {
          cp = $&.unpack('U')[0]
          (e = reverse_map[cp]) ?  "&#{e};" : $&
        }
      when :decimal
        output = (output || string).gsub(UTF8_NON_ASCII_REGEXP) {
          "&##{$&.unpack('U')[0]};"
        }
      when :hexadecimal
        output = (output || string).gsub(UTF8_NON_ASCII_REGEXP) {
          "&#x#{$&.unpack('U')[0].to_s(16)};"
        }
      end
    end
    return output
  end

private

  def map
    @map ||= (require "htmlentities/#{@flavor}"; HTMLEntities::MAPPINGS[@flavor])
  end

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

  def named_entity_regexp
    @named_entity_regexp ||= (
      min_length = map.keys.map{ |a| a.length }.min
      max_length = map.keys.map{ |a| a.length }.max
      /&([a-z][a-z0-9]{#{min_length-1},#{max_length-1}});/i
    )
  end

  def reverse_map
    @reverse_map ||= map.invert
  end

end
