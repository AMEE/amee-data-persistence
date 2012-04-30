# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "amee-data-persistence"
  s.version = "2.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Hetherington", "Andrew Berkeley", "James Smith", "George Palmer"]
  s.date = "2012-04-30"
  s.description = "Part of the AMEEappkit, this gem provides storage and retrival of data provided by the amee-data-abstraction gem"
  s.email = "help@amee.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.txt"
  ]
  s.files = [
    ".rvmrc",
    "CHANGELOG.txt",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.txt",
    "Rakefile",
    "VERSION",
    "amee-data-persistence.gemspec",
    "amee-data-persistence.tmproj",
    "lib/amee-data-persistence.rb",
    "lib/amee/data_abstraction/calculation_collection.rb",
    "lib/amee/data_abstraction/ongoing_calculation_persistence_support.rb",
    "lib/amee/db/calculation.rb",
    "lib/amee/db/config.rb",
    "lib/amee/db/term.rb",
    "lib/generators/persistence/persistence_generator.rb",
    "lib/generators/persistence/templates/config/persistence.yml.erb",
    "lib/generators/persistence/templates/db/migrate/001_create_persistence_tables.rb",
    "lib/generators/persistence/templates/db/migrate/002_add_unit_columns.rb",
    "lib/generators/persistence/templates/db/migrate/003_add_value_types.rb",
    "lib/generators/persistence/templates/db/migrate/004_change_term_column_type.rb",
    "spec/amee/db/calculation_spec.rb",
    "spec/amee/db/config_spec.rb",
    "spec/amee/db/ongoing_calculation_persistence_support_spec.rb",
    "spec/amee/db/term_spec.rb",
    "spec/amee/fixtures/config/calculations/electricity.lock.rb",
    "spec/amee/fixtures/config/calculations/electricity.rb",
    "spec/database.yml",
    "spec/spec.opts",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/AMEE/amee-data-persistence"
  s.licenses = ["BSD 3-Clause"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Persistent storage of calculations performed against the AMEE API"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<amee-data-abstraction>, ["~> 2.2.0"])
      s.add_runtime_dependency(%q<activerecord>, ["~> 3.2.1"])
      s.add_development_dependency(%q<bundler>, ["~> 1.1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rspec>, ["= 2.6.0"])
      s.add_development_dependency(%q<flexmock>, ["> 0.8.6"])
      s.add_development_dependency(%q<rdoc>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
    else
      s.add_dependency(%q<amee-data-abstraction>, ["~> 2.2.0"])
      s.add_dependency(%q<activerecord>, ["~> 3.2.1"])
      s.add_dependency(%q<bundler>, ["~> 1.1.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rspec>, ["= 2.6.0"])
      s.add_dependency(%q<flexmock>, ["> 0.8.6"])
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
    end
  else
    s.add_dependency(%q<amee-data-abstraction>, ["~> 2.2.0"])
    s.add_dependency(%q<activerecord>, ["~> 3.2.1"])
    s.add_dependency(%q<bundler>, ["~> 1.1.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rspec>, ["= 2.6.0"])
    s.add_dependency(%q<flexmock>, ["> 0.8.6"])
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
  end
end

