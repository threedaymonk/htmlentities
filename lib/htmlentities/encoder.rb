class HTMLEntities
  InstructionError = Class.new(RuntimeError)

  class Encoder #:nodoc:
    INSTRUCTIONS = [:basic, :named, :decimal, :hexadecimal, :four_byte]

    def initialize(flavor, instructions)
      @flavor = flavor
      @instructions = instructions.empty? ? [:basic] : instructions
      validate_instructions
      build_basic_entity_encoder
      build_extended_entity_encoder
    end

    def encode(source)
      minimize_encoding(
        replace_extended(
          replace_basic(
            prepare(source))))
    end

  private

    def prepare(string)
      string.to_s.encode(Encoding::UTF_8)
    end

    def minimize_encoding(string)
      if string.encoding != Encoding::ASCII && contains_only_ascii?(string)
        string.encode(Encoding::ASCII)
      else
        string
      end
    end

    def contains_only_ascii?(string)
      string.match(/\A[\x01-\x7F]*\z/)
    end

    def basic_entity_regexp
      @basic_entity_regexp ||= @flavor.match(/^html/) ? /[<>"&]/ : /[<>'"&]/
    end

    def extended_entity_regexp
      @extended_entity_regexp ||= (
        pattern = '[^\u{20}-\u{7E}]'
        pattern << "|'" if @flavor == 'html4'
        Regexp.new(pattern)
      )
    end

    def replace_basic(string)
      string.gsub(basic_entity_regexp) do |match|
        if @instructions.include?(:four_byte) && match.bytes.length != 4
          match
        else
          encode_basic(match)
        end
      end
    end

    def replace_extended(string)
      string.gsub(extended_entity_regexp) do |match|
        if @instructions.include?(:four_byte) && match.bytes.length != 4
          match
        else
          encode_extended(match)
        end
      end
    end

    def validate_instructions
      unknown_instructions = @instructions - INSTRUCTIONS
      if unknown_instructions.any?
        raise InstructionError,
          "unknown encode_entities command(s): #{unknown_instructions.inspect}"
      end

      if @instructions.include?(:decimal) && @instructions.include?(:hexadecimal)
        raise InstructionError,
          "hexadecimal and decimal encoding are mutually exclusive"
      end
    end

    def build_basic_entity_encoder
      if @instructions.include?(:basic) || @instructions.include?(:named)
        method = :encode_named
      elsif @instructions.include?(:decimal)
        method = :encode_decimal
      elsif @instructions.include?(:hexadecimal)
        method = :encode_hexadecimal
      end
      instance_eval <<-END
        def encode_basic(char)
          #{method}(char)
        end
      END
    end

    def build_extended_entity_encoder
      operations = [:named, :decimal, :hexadecimal] & @instructions
      instance_eval <<-END
        def encode_extended(char)
          #{operations.map{ |encoder| %{
            encoded = encode_#{encoder}(char)
            return encoded if encoded
          }}.join("\n")}
          char
        end
      END
    end

    def encode_named(char)
      cp = char.codepoints.first
      (e = reverse_map[cp]) && "&#{e};"
    end

    def encode_decimal(char)
      "&##{char.codepoints.first};"
    end

    def encode_hexadecimal(char)
      "&#x#{char.codepoints.first.to_s(16)};"
    end

    def reverse_map
      @reverse_map ||= (
        skips = HTMLEntities::SKIP_DUP_ENCODINGS[@flavor]
        map = HTMLEntities::MAPPINGS[@flavor]
        uniqmap = skips ? map.reject{|ent,hx| skips.include? ent} : map
        uniqmap.invert
      )
    end
  end
end
