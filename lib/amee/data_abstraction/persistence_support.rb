module AMEE
  module DataAbstraction
    module PersistenceSupport
      
      def save!
        puts 'saving to persistence layer'
        record = AMEE::Db::Calculation.find_or_initialize_by_profile_item_uid(self.profile_item_uid)
        record.update_calculation!(self.to_hash)
      end
      
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def find(ordinality, options = {})
          unless [:all, :first].include? ordinality
            raise ArgumentError.new("First argument should be :all or :first") 
          end

          puts 'finding things from persistence layer'

          if calc_from_db = AMEE::Db::Calculation.find(ordinality, options = {})
            calc = Calculations[calc_from_db.calculation_type].begin_calcuation
    		    calc.choose!(calc_from_db.to_hash)
    		    return calc
          end
          return nil
        end
      end

    end
  end
end