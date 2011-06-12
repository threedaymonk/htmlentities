Gem::Specification.new do |s|
	s.name   = "htmlentities"
	s.version = "3.0.1"
	s.author = "Paul Battley"
	s.email = "pbattley@gmail.com"
	s.summary = "A module for encoding and decoding of HTML/XML entities from/to their corresponding UTF-8 codepoints. Optional String class extension for same."
	s.files = Dir['{lib,test}/**/*.rb']
	s.require_path = "lib"
	s.test_file = 'test/all.rb'
	s.has_rdoc = true
	s.extra_rdoc_files = %w[README CHANGES COPYING]
end