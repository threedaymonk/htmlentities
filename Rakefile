require "rake/testtask"
require "rake/clean"

CLEAN.include("doc")
FLAVORS = %w[html4 xhtml1 expanded]
DATA_FILES = FLAVORS.map{ |d| "lib/htmlentities/mappings/#{d}.rb" }
SOURCES = FileList["lib/**/*.rb"] - DATA_FILES

task :default => [:entities, :test]

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.ruby_opts << "-w"
  t.verbose = true
end

%w[html4 xhtml].each do |name|
  file "lib/htmlentities/mappings/#{name}.rb" => %w[util/build_html_entities.rb] do |f|
    sh %{ruby util/build_html_entities.rb #{name} > #{f.name}}
  end
end

file "lib/htmlentities/mappings/expanded.rb" => %w[util/build_expanded_entities.rb] do |f|
  sh %{ruby util/build_expanded_entities.rb > #{f.name}}
end

file "doc" => SOURCES do |f|
  sh %{rdoc #{SOURCES.join(' ')}}
end

task :entities => DATA_FILES

desc "Run benchmark"
task :benchmark do |t|
  system "ruby -v"
  system "ruby perf/benchmark.rb"
end

desc "Use profiler to analyse encoding and decoding"
task :profile do |t|
  system "ruby -v"
  system "ruby perf/profile.rb"
end
