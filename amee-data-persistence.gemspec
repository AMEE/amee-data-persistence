require 'rake'

Gem::Specification.new do |s|
  s.name = "amee-data-persistence"
  s.version = '0.0.1'
  s.date = "2011-03-24"
  s.summary = ""
  s.email = "james@floppy.org.uk"
  s.homepage = "http://github.com/AMEE/amee-data-persistence"
  s.has_rdoc = true
  s.authors = ["James Smith", "Andrew Berkeley"]
  s.files = ::FileList.new('lib/**/*.rb')
  s.files += ['init.rb', 'rails/init.rb']
  s.add_dependency("amee-data-abstraction")
end
