require 'rake'

Gem::Specification.new do |s|
  s.name = "amee-data-persistence"
  s.version = '0.2.2'
  s.date = "2011-05-05"
  s.summary = ""
  s.email = "james@floppy.org.uk"
  s.homepage = "http://github.com/AMEE/amee-data-persistence"
  s.has_rdoc = true
  s.authors = ["James Smith", "Andrew Berkeley","James Hetherington"]
  s.files = ::FileList.new('lib/**/*.rb')
  s.files += ['init.rb', 'rails/init.rb']
  s.files += ::FileList.new('spec/**/*.rb')
  s.files += ['spec/spec_helper.rb', 'spec/database.yml', 'spec/spec.opts']
  s.add_dependency("amee-data-abstraction",">= 0.4.4")
end
