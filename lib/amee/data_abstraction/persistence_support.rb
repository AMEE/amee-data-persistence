module AMEE
  module DataAbstraction
    module PersistenceSupport

      def self.included(base)
        base.extend ClassMethods
      end

      attr_accessor :db_calculation
      
      def save
        record = db_calculation || get_db_calculation
        record.update_calculation!(to_hash)
        true
      rescue ActiveRecord::RecordNotSaved
        false
      end

      def delete
        record = db_calculation || get_db_calculation
        self.db_calculation = nil
        AMEE::Db::Calculation.delete record.id
      end

      def get_db_calculation
        self.db_calculation = AMEE::Db::Calculation.find_or_initialize_by_profile_item_uid(send :profile_item_uid)
      end

      def stored_terms
        stored_terms = []
        stored_terms += metadata if OngoingCalculation.store_metadata?
        stored_terms += inputs if OngoingCalculation.store_inputs?
        stored_terms += outputs if OngoingCalculation.store_outputs?
        stored_terms
      end

      def to_hash(representation=:stored_terms_only)
        hash = {}
        hash[:calculation_type] = label
        hash[:profile_item_uid] = send :profile_item_uid
        hash[:profile_uid] = send :profile_uid
        (representation == :full ? terms : stored_terms ).each do |term|
          hash[term.label.to_sym] = (term.unit.nil? ? term.value : "#{term.value} #{term.unit}")
        end
        return hash
      end

      module ClassMethods

        def find(ordinality, options = {})
          unless [:all, :first].include? ordinality
            raise ArgumentError.new("First argument should be :all or :first") 
          end

          result = AMEE::Db::Calculation.find(ordinality, options)
          return nil unless result

          if ordinality==:first
            initialize_from_db_record(result)
          else
            result.compact.map do |calc|
              initialize_from_db_record(calc)
            end
          end
        end

        def find_by_type(ordinality,type)
          OngoingCalculation.find(ordinality, :conditions => {:calculation_type => type.to_s})
        end

        def initialize_from_db_record(record)
          unless record.is_a? AMEE::Db::Calculation
            raise ArgumentError.new("Argument is not of class AMEE::Db::Calculation")
          end
          calc = Calculations.calculations[record.type].begin_calculation
          calc.db_calculation = record
    		  calc.choose!(record.to_hash)
          return calc
        end

        def storage_config
          AMEE::Db::BaseConfig.new
        end

        def storage_method
          storage_config.storage_method
        end

        def store_inputs?
          storage_config.store_everything?
        end

        def store_outputs?
          storage_config.store_outputs?
        end

        def store_metadata?
          storage_config.store_metadata?
        end

      end

    end
  end
end