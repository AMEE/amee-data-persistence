module AMEE
  module DataAbstraction
    module PersistenceSupport
      
      def save
        puts 'saving to persistence layer'
        record = AMEE::Db::Calculation.find_or_initialize_by_profile_item_uid(send :profile_item_uid)
        record.update_calculation!(to_hash)
      end

      def to_hash
        hash = {}
        hash[:calculation_type] = label
        hash[:profile_item_uid] = send :profile_item_uid
        hash[:profile_uid] = send :profile_uid
        terms.each do |term|
          hash[term.label.to_sym] = (term.unit.nil? ? term.value : "#{term.value} #{term.unit}")
        end
        return hash
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
            calc = Calculations.calculations[calc_from_db.type].begin_calculation
    		    calc.choose!(calc_from_db.to_hash)
    		    return calc
          end
          return nil
        end
      end

    end
  end
end