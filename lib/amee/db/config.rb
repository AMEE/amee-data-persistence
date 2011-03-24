require 'singleton'

module AMEE
  module Db
    
    # A singleton class for configuration. Automatically initialised on first use
    # Use like so:
    # AMEE::Db::Config.instance.store_everything?
    
    # Separated into BaseConfig and Config to allow unit testing of singleton.
    
    class BaseConfig
    
      def initialize
        # Default is metadata
        @storage_method = load_storage_method || :metadata
      end
            
      attr_reader :storage_method

      def store_metadata?
        [:metadata, :outputs, :everything].include? storage_method
      end

      def store_outputs?
        [:outputs, :everything].include? storage_method
      end

      def store_everything?
        [:everything].include? storage_method
      end

      private
      
      def load_storage_method
        m = YAML.load_file("#{RAILS_ROOT}/config/persistence.yml")['method'].to_sym rescue nil
        raise "amee-data-persistence: Invalid storage method" unless [:metadata, :outputs, :everything].include? m
        m
      end

    end
    
    class Config < BaseConfig
      include Singleton
    end
      
  end
end