module AMEE
  module DataAbstraction
    module PersistenceSupport
      
      def save
        puts 'saving to persistence layer'
        false
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
          OngoingCalculation.new
        end
      end

    end
  end
end