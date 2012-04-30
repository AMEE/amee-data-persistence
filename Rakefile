# Copyright (C) 2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'rspec'
require 'rspec/core/rake_task'

task :default => [:spec]

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  # Put spec opts in a file named .rspec in root
end

require 'jeweler'
# Fix for Jeweler to use stable branch
class Jeweler
  module Commands
    class ReleaseToGit
      def run
        unless clean_staging_area?
          system "git status"
          raise "Unclean staging area! Be sure to commit or .gitignore everything first. See `git status` above."
        end
        repo.checkout('stable')
        repo.push('origin', 'stable')
        if release_not_tagged?
          output.puts "Tagging #{release_tag}"
          repo.add_tag(release_tag)
          output.puts "Pushing #{release_tag} to origin"
          repo.push('origin', release_tag)
        end
      end
    end
    class ReleaseGemspec
      def run
        unless clean_staging_area?
          system "git status"
          raise "Unclean staging area! Be sure to commit or .gitignore everything first. See `git status` above."
        end
        repo.checkout('stable')
        regenerate_gemspec!
        commit_gemspec! if gemspec_changed?
        output.puts "Pushing stable to origin"
        repo.push('origin', 'stable')
      end
    end
  end
end

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "amee-data-persistence"
  gem.homepage = "http://github.com/AMEE/amee-data-persistence"
  gem.license = "BSD 3-Clause"
  gem.summary = %Q{Persistent storage of calculations performed against the AMEE API}
  gem.description = %Q{Part of the AMEEappkit, this gem provides storage and retrival of data provided by the amee-data-abstraction gem}
  gem.email = "help@amee.com"
  gem.authors = ["James Hetherington", "Andrew Berkeley", "James Smith", "George Palmer"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rdoc/task'
RDoc::Task.new do |rd|
  rd.title = "AMEE Data Persistence"
  rd.rdoc_dir = 'doc'
  rd.main = "README"
  rd.rdoc_files.include("README", "lib/**/*.rb")
end
