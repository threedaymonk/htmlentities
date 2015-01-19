#!/usr/bin/env ruby
require 'open-uri'
require 'uri'

ENTITIES_URL = 'ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/MISC/SGML.TXT'
LINE_PATTERN = /^([^#]\S+)\s+(\S+)\s+0x([0-9A-F]+)\s+# (.*?)$/

list = open(ENTITIES_URL){ |io| io.read }
entities = Hash[list.scan(LINE_PATTERN).map { |name, *rest| [name, rest] }]

# override apos for consistency with previous version
entities['apos'] = ['', '0027', 'for consistency']

puts <<END
# encoding: UTF-8
class HTMLEntities
  MAPPINGS['expanded'] = {
END

entities.each do |name, (set, hex, comment)|
  char = [hex.to_i(16)].pack('U')
  qname = "'#{name}'".ljust(10)
  puts "    #{qname} => 0x#{hex}, # #{char} #{comment.strip}"
end

puts <<END
  }
end
END
