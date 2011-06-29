
# Authors::   James Hetherington, James Smith, Andrew Berkeley, George Palmer
# Copyright:: Copyright (c) 2011 AMEE UK Ltd
# License::   Permission is hereby granted, free of charge, to any person obtaining
#             a copy of this software and associated documentation files (the
#             "Software"), to deal in the Software without restriction, including
#             without limitation the rights to use, copy, modify, merge, publish,
#             distribute, sublicense, and/or sell copies of the Software, and to
#             permit persons to whom the Software is furnished to do so, subject
#             to the following conditions:
#
#             The above copyright notice and this permission notice shall be included
#             in all copies or substantial portions of the Software.
#
#             THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#             EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#             MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#             IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#             CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#             TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#             SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# :title: Class: AMEE::Db::BaseConfig

require 'singleton'

module AMEE
  module Db
    
    # A singleton class for configuration. Automatically initialised on first use
    # Use like so:
    #
    #   AMEE::Db::Config.instance.store_everything?
    #
    # Separated into BaseConfig and Config to allow unit testing of singleton.
    #
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