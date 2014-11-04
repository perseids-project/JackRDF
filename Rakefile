require 'bundler/gem_tasks'
require 'rake/testtask'
require 'sparql_model'

Rake::TestTask.new do |t|
  t.libs = ['test']
  t.warning = true
  t.verbose = true
  t.test_files = FileList[ 'test/*rb' ]
end

FUSEKI_VERSION = "1.0.2"
FUSEKI_DIR = "jena-fuseki-#{FUSEKI_VERSION}"
FUSEKI_TAR = "#{FUSEKI_DIR}-distribution.tar.gz"
FUSEKI_EXE = "fuseki/#{FUSEKI_DIR}/fuseki-server"
FUSEKI_TRIPLES = "/var/www/JackRDF/triples"
FUSEKI_HOST = "http://localhost"
FUSEKI_PORT = "4321"
FUSEKI_DATASTORE = "ds"
FUSEKI_ENDPOINT = "#{FUSEKI_HOST}:#{FUSEKI_PORT}/#{FUSEKI_DATASTORE}"

desc "Run tests"
task :default => :test

namespace :data do
  desc 'Destroy all Fuseki data'
  task :destroy do
    STDOUT.puts "Sure you want to destroy all triples in #{FUSEKI_ENDPOINT}? (y/n)"
    input = STDIN.gets.strip
    if input == 'y'
      quick = SparqlQuick.new( FUSEKI_ENDPOINT )
      quick.empty( :all )
    else
      STDOUT.puts "No triples were destroyed.  It's still all there :)"
    end
  end
end

namespace :server do
  desc 'Download and install Fuseki'
  task :install do
    `curl -O http://archive.apache.org/dist/jena/binaries/#{FUSEKI_TAR}`
    `mkdir fuseki`
    `tar xzvf #{FUSEKI_TAR} -C fuseki`
    `chmod +x #{FUSEKI_EXE} fuseki/#{FUSEKI_DIR}/s-**`
    `rm #{FUSEKI_TAR}`
  end

  desc "Start the Fuseki test server at port #{FUSEKI_PORT}"
  task :start do
    `mkdir -p #{FUSEKI_TRIPLES}`
    Dir.chdir("#{FUSEKI_DIR}") do
      IO.popen("./fuseki-server --update --loc=#{FUSEKI_TRIPLES} --port=#{FUSEKI_PORT} /#{FUSEKI_DATASTORE}") do |f|
        f.each { |l| puts l }
      end
    end
  end
end

