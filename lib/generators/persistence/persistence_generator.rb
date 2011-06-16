class PersistenceGenerator < Rails::Generator::Base

  # Need to explicitly define the paths to both the templates directory and the
  # standard application migrations directory. These are equivalent when using
  # the #template method it is assumed therein that there is a mapping to the
  # /templates directory for the generator templates (and from there the sub-
  # paths are the same). This assumption is not valid when accessing the
  # templates and the existing application migrations otherwise.
  #
  DEFAULT_MIGRATION_PATH = File.join("db/migrate")
  TEMPLATE_MIGRATION_PATH = File.join(File.dirname(__FILE__),"templates",DEFAULT_MIGRATION_PATH)

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



      #######################
      # database migrations #
      #######################

      # Check db/migrate exists
      m.directory DEFAULT_MIGRATION_PATH
      # Create migrations if not already represented
      migration_template_files.each_with_index do |file_name,index|
        unless migration_exists? file_name
          template_path = File.join(DEFAULT_MIGRATION_PATH,file_name)
          # increment timestamp to differentiate files generated within same second
          destination_file_name = file_name.gsub(/\d{3}/,"#{Time.now.strftime("%Y%m%d%I%M%S").to_i+index}")
          destination_path = File.join(DEFAULT_MIGRATION_PATH,destination_file_name)
          
          m.template template_path, destination_path
        else
          # print to stdout in standard migration reporting format
          puts "      exists  migration content in template: #{file_name}"
        end
      end

    end
  end

  # Get names of all migration template files and sort them by version number
  def migration_template_files
    Dir.new(TEMPLATE_MIGRATION_PATH).entries.reject { |entry| File.directory? entry }.sort
  end

  # Check whether a migration already exists, by comparing the content of the
  # migration template with any migrations which already exist in the
  # applicaition's db/migrate directory. This is preferable to using file names
  # since file names (1) have a time stamp and are therefore not consistent
  # between separate instances of a file generation and (2) migration names may
  # be changed in the future.
  #
  def migration_exists?(template)
    template_content = File.read(File.join(TEMPLATE_MIGRATION_PATH,template))

    Dir.new(DEFAULT_MIGRATION_PATH).entries.any? do |file|
      next if File.directory?(file)
      File.read(File.join(DEFAULT_MIGRATION_PATH,file)) == template_content
    end
  end

end