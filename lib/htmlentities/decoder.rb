class HTMLEntities
  class Decoder #:nodoc:
    def initialize(flavor)
      @flavor = flavor
      @map = HTMLEntities::MAPPINGS[@flavor]
      @named_entity_regexp = named_entity_regexp
    end

    def decode(source)
      source.to_s.gsub(@named_entity_regexp) {
        (codepoint = @map[$1]) ? [codepoint].pack('U') : $&
      }.gsub(/&#(?:([0-9]{1,7})|x([0-9a-f]{1,6}));/i) {
        $1 ? [$1.to_i].pack('U') : [$2.to_i(16)].pack('U')
      }
    end

  private
    def named_entity_regexp
      key_lengths = @map.keys.map{ |k| k.length }
      entity_name_pattern =
        if @flavor == 'expanded'
          '(?:b\.)?[a-z][a-z0-9]'
        else
          '[a-z][a-z0-9]'
        end
      /&(#{ entity_name_pattern }{#{ key_lengths.min - 1 },#{ key_lengths.max - 1 }});/i
    end
  end
end
