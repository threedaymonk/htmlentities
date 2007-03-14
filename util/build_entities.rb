#!/usr/bin/env ruby
require 'open-uri'
require 'uri'

DTD = {
  'html4'   => 'http://www.w3.org/TR/html4/strict.dtd',
  'xhtml1'  => 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
}

# Start off with an XHTML DTD
flavor = ARGV.first
dtd_uri = DTD[flavor]
entities = {}

dtd = open(dtd_uri){ |io| io.read }
dtd.scan(/<!ENTITY \s+ % \s+ (\w+) \s+ PUBLIC \s+ "(.*?)" \s+ "(.*?)" \s* >/x) do |m|
  entity_file = URI.parse(dtd_uri).merge(m[2]).to_s
  $stderr.puts("Found reference to entity file at #{entity_file}")
  entities_found = 0
  entity = open(entity_file){ |io| io.read }
  entity.scan(/<!ENTITY \s+ (\w+) \s+ (?:CDATA \s+)? "\&\#(.*?);"/x) do |m|
    name, codepoint = m
    case codepoint
    when /^\d/
      entities[name] = codepoint.to_i
    when /^x\d/
      entities[name] = codepoint[1,-1].to_i(16)
    else
      raise "couldn't parse entity definition #{m[0]}"
    end
    entities_found += 1
  end
  $stderr.puts("Found #{entities_found} entities in #{entity_file}")
end

# These two are a special case in the W3C entity file, so fix them:
entities['lt']  = ?<
entities['amp'] = ?&

puts <<"END"
class HTMLEntities
  MAPPINGS = {} unless defined? MAPPINGS
  MAPPINGS['#{flavor}'] = {
#{
  entities.keys.sort_by{ |s| 
    [s.downcase, s] 
  }.map{ |name| 
    "    '#{name}' => #{entities[name]}"
  }.join(",\n")
}
  }
end
END
