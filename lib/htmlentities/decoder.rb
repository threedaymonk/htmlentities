class HTMLEntities
  class Decoder #:nodoc:
    def initialize(flavor)
      @flavor = flavor
    end

    def decode(source)
      source.to_s.gsub(named_entity_regexp) {
        (cp = map[$1]) ? [cp].pack('U') : $&
      }.gsub(/&#([0-9]{1,7});|&#x([0-9a-f]{1,6});/i) {
        $1 ? [$1.to_i].pack('U') : [$2.to_i(16)].pack('U')
      }
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
  end
end
