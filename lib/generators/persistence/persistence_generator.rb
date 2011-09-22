require 'rails/generators/migration'
require 'rails/generators/active_record'

class PersistenceGenerator < Rails::Generators::Base

  include Rails::Generators::Migration

  desc "Generates a migration for the AMEE Organisation models"
  def self.source_root
    @source_root ||= File.dirname(__FILE__) + '/templates'
  end

  def self.next_migration_number(path)
    ActiveRecord::Generators::Base.next_migration_number(path)
  end

  def generate_migration
    migration_template 'db/migrate/001_create_persistence_tables.rb', 'db/migrate/create_persistence_tables'
    migration_template 'db/migrate/002_add_unit_columns.rb', 'db/migrate/add_unit_columns'
    migration_template 'db/migrate/003_add_value_types.rb', 'db/migrate/add_value_types'
  end

  def manifest
    record do |m|
      
      ########################################
      # persistence level configuration file #
      ########################################

      # Get method from command line - default is metadata
      method = args[0] || 'metadata'
      # Make sure there is a config directory
      m.directory File.join("config")
      # Create persistence.yml file
      m.template File.join("config","persistence.yml.erb"),
                 File.join("config","persistence.yml"),
                 :assigns => {:method => method}

    end
  end
end