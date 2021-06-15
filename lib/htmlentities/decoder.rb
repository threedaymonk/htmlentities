class HTMLEntities
  class Decoder #:nodoc:
    def initialize(flavor)
      @flavor = flavor
      @map = HTMLEntities::MAPPINGS[@flavor]
      @entity_regexp = entity_regexp
    end

    def decode(source, tolerate_capitalization_mistakes: false)
      prepare(source).gsub(@entity_regexp){
        if $1 && codepoint = lookup_mapping($1, case_insensitive: tolerate_capitalization_mistakes)
          codepoint.chr(Encoding::UTF_8)
        elsif $2
          $2.to_i(10).chr(Encoding::UTF_8)
        elsif $3
          $3.to_i(16).chr(Encoding::UTF_8)
        else
          $&
        end
      }
    end

  private

    def lookup_mapping(entity, case_insensitive:)
      @map.fetch(entity) do
        if case_insensitive
          @map[entity.downcase]
        else
          nil
        end
      end
    end

    def prepare(string) #:nodoc:
      string.to_s.encode(Encoding::UTF_8)
    end

    def entity_regexp
      key_lengths = @map.keys.map{ |k| k.length }
      if @flavor == 'expanded'
        entity_name_pattern = '(?:b\.)?[a-z][a-z0-9]'
      else
        entity_name_pattern = '[a-z][a-z0-9]'
      end
      /&(?:(#{entity_name_pattern}{#{key_lengths.min - 1},#{key_lengths.max - 1}})|#([0-9]{1,7})|#x([0-9a-f]{1,6}));/i
    end
  end
end
