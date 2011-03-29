
module AMEE
  module Db
    class Term < ActiveRecord::Base

      belongs_to :calculation, :class_name => "AMEE::Db::Calculation"
      validates_presence_of :calculation_id, :label, :value
      before_save :initialize_value

      def update_value!(value)
        self.value = value
        raise InvalidRecord, "Term record invalid" unless save!
      end

      def initialize_value
        if value.is_a? Quantify::Quantity
          self.value = value.to_s(:label)
        else
          self.value = value.to_s
        end
      end
      
      def value_or_quantity_object
        Quantify::Quantity.parse value
      rescue Quantify::QuantityParseError
        value
      end

      def to_hash
        { label.to_sym => value_or_quantity_object }
      end

    end
  end
end
