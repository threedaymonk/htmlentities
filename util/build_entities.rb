#!/usr/bin/env ruby
require 'open-uri'
require 'uri'

DTD_URI = 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
entities = {}

dtd = open(DTD_URI){ |io| io.read }
dtd.scan(/<!ENTITY \s+ % \s+ (\w+) \s+ PUBLIC \s+ "(.*?)" \s+ "(.*?)" \s* >/x) do |m|
  entity = open(URI.parse(DTD_URI).merge(m[2]).to_s){ |io| io.read }
  entity.scan(/<!ENTITY \s+ (\w+) \s+ "\&\#(.*?);" \s*>/x) do |m|
    name, codepoint = m
    case codepoint
    when /^\d/
      entities[name] = codepoint.to_i
    when /^x\d/
      entities[name] = codepoint[1,-1].to_i(16)
    end
  end
end

puts "module HTMLEntities"
puts "  module Data"
puts "    MAP = {"
puts(entities.keys.sort_by{ |s| [s.downcase, s] }.map{ |name| "      '#{name}' => #{entities[name]}" }.join(",\n"))
puts "    }"
puts "  end"
puts "end"
