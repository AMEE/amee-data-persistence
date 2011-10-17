# Copyright (C) 2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

# :title: Class AMEE::Db::Term

module AMEE
  module Db

    # This class represents a database record for a calculation term used with
    # the <i>AMEE:DataAbstraction::OngoingCalculation</i> class. This class stores
    # the label, value and unit attributes of specific calculation terms, and is
    # owned by an associated <i>AMEE::Db::Calculation</i> record
    #
    # This class is typically used by proxy, via the <tt>#update_calculation!</tt>,
    # and <tt>#to_hash</tt> methods of the <i>AMEE::Db::Calculation</i> class, and
    # ultimately called from the <tt>find</tt>, <tt>find_by_type</tt>,
    # <tt>#save</tt>, <tt>#delete</tt>, and <tt>#get_db_calculation</tt> methods
    # associated with the <i>AMEE:DataAbstraction::OngoingCalculation</i> class.
    #
    class Term < ActiveRecord::Base

      belongs_to :calculation, :class_name => "AMEE::Db::Calculation"
      validates :calculation_id, :presence => true
      validates :label,          :presence => true
      before_save :initialize_units
      before_save :initialize_value

      # Returns a <i>Hash</i> representation of <tt>self</tt>, e.g.
      #
      #   my_term.to_hash       #=> { :value => 1600,
      #                               :unit => <Quantify::Unit::SI> }
      #
      #   my_term.to_hash       #=> { :value => 234.1,
      #                               :unit => <Quantify::Unit::NonSI>,
      #                               :per_unit => <Quantify::Unit::SI> }
      #
      # This method is called as part of <tt>AMEE::Db::Calculation#to_hash</tt>
      # in order to provide a full hash representation of a calculation.
      #
      def to_hash
        sub_hash = {}
        # Float method called on term value in order to initialize
        # explicitly numeric values as numeric objects.
        #
        sub_hash[:value] = AMEE::DataAbstraction::Term.convert_value_to_type(self.value, self.value_type)
        sub_hash[:unit] = Unit.for(unit) if unit
        sub_hash[:per_unit] = Unit.for(per_unit) if per_unit
        { label.to_sym => sub_hash }
      end

      private

      # Serialize all unit attributes using the string provided by the
      # <tt>label</tt> attribute of a <i>Quantify::Unit::Base</i> object
      #
      def initialize_units
        if unit
          self.unit = unit.is_a?(Quantify::Unit::Base) ? unit.label : unit
        end
        if per_unit
          self.per_unit = per_unit.is_a?(Quantify::Unit::Base) ? per_unit.label : per_unit
        end
      end
      
      def initialize_value
        unless self.value.nil?
          self.value_type = self.value.class.to_s
          self.value      = self.value.to_s
        end
      end
    end
  end
end
