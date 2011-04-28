
module AMEE
  module Db
    class Term < ActiveRecord::Base

      belongs_to :calculation, :class_name => "AMEE::Db::Calculation"
      validates_presence_of :calculation_id, :label
      before_save :initialize_units

      def initialize_units
        self.unit = unit.label if unit
        self.per_unit = per_unit.label if per_unit
      end

      def to_hash
        sub_hash = {}
        sub_hash[:value] = value
        sub_hash[:unit] = Unit.for(unit) if unit
        sub_hash[:per_unit] = Unit.for(per_unit) if per_unit
        { label.to_sym => sub_hash }
      end

    end
  end
end
