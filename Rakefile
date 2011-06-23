require "rake/testtask"
require "rake/clean"

CLEAN.include("doc")
DOCTYPES = %w[html4 xhtml1]
DATA_FILES = DOCTYPES.map{ |d| "lib/htmlentities/#{d}.rb" }
SOURCES = FileList["lib/**/*.rb"] - DATA_FILES

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.ruby_opts << "-w"
  t.verbose = true
end

DOCTYPES.each do |name|
  file "lib/htmlentities/#{name}.rb" => %w[util/build_entities.rb] do |f|
    rm_f f.name
    sh %{ruby util/build_entities.rb #{name} > #{f.name}}
  end
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
