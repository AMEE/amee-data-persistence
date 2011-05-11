module AMEE
  module DataAbstraction
    module PersistenceSupport

      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          alias_method :basic_delete_profile_item, :delete_profile_item
        end
        base.send :define_method, 'delete_profile_item' do
          basic_delete_profile_item
          delete
        end
      end

      attr_accessor :db_calculation

      def id
        db_calculation.nil? ? nil : db_calculation.id
      end
      
      def save
        validate!
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
          sub_hash = {}
          sub_hash[:value] = term.value
          sub_hash[:unit] = term.unit if term.unit
          sub_hash[:per_unit] = term.per_unit if term.per_unit
          hash[term.label.to_sym] = sub_hash
        end
        return hash
      end

      module ClassMethods

        def find(*args)
          result = AMEE::Db::Calculation.find(*args)
          return nil unless result
          if result.respond_to?(:map)
            result.compact.map do |calc|
              initialize_from_db_record(calc)
            end
          else
            initialize_from_db_record(result)
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
          # Means that validation needs to occur before calcs are saved
    		  calc.choose_without_validation!(record.to_hash)
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