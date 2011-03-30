module AMEE
  module DataAbstraction
    module PersistenceSupport
      
      def save
        puts 'saving to persistence layer'
        record = AMEE::Db::Calculation.find_or_initialize_by_profile_item_uid(send :profile_item_uid)
        record.update_calculation!(to_hash)
      end

      def to_hash
        hash = ActiveSupport::OrderedHash.new
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
          calcs_from_db = AMEE::Db::Calculation.find(ordinality, options)
          return nil unless calcs_from_db
          if ordinality==:first
            calc = Calculations.calculations[calcs_from_db.type].begin_calculation
    		    calc.choose!(calcs_from_db.to_hash)
    		    return calc
          else
            calcs_from_db.compact.map{|calc_from_db|
              calc = Calculations.calculations[calc_from_db.type].begin_calculation
    		      calc.choose!(calc_from_db.to_hash)
              calc
            }
          end
        end
      end

    end
  end
end