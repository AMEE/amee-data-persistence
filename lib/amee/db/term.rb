module AMEE
  module Db
    class Term < ActiveRecord::Base

      belongs_to :calculation, :class_name => "AMEE::Db::Calculation"
      validates_presence_of :calculation_id, :label

      def update_value!(value)
        self.value = value
        save!
      end

      def to_hash
        { label.to_sym => value }
      end

    end
  end
end
