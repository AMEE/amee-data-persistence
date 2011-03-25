class PersistenceGenerator < Rails::Generator::Base
  def manifest # this method is default entrance of generator
    record do |m|
      # Get method from command line - default is metadata
      method = args[0] || 'metadata'
      # Make sure there is a config directory
      m.directory File.join("config")
      # Create persistence.yml file
      m.template File.join("config","persistence.yml.erb"), 
                 File.join("config","persistence.yml"), 
                 :assigns => {:method => method}
     # Create migration
     m.template File.join("db","migrations","migration.rb.erb"), 
                File.join("db","migrations","migration.rb")
    end
  end
end