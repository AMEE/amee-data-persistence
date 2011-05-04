class PersistenceGenerator < Rails::Generator::Base
  def manifest # this method is the default entry point
    record do |m|
      # Get method from command line - default is metadata
      method = args[0] || 'metadata'
      # Make sure there is a config directory
      m.directory File.join("config")
      # Create persistence.yml file
      m.template File.join("config","persistence.yml.erb"), 
                 File.join("config","persistence.yml"), 
                 :assigns => {:method => method}
      # Check db/migrate exists
      m.directory File.join("db/migrate")
      # Create migration
      m.template File.join("db","migrate","001_create_tables.rb"),
                 File.join("db","migrate","#{Time.now.strftime("%Y%m%d%I%M%S")}_create_tables.rb")
    end
  end
end