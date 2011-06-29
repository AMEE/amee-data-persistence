
# Authors::   James Hetherington, James Smith, Andrew Berkeley, George Palmer
# Copyright:: Copyright (c) 2011 AMEE UK Ltd
# License::   Permission is hereby granted, free of charge, to any person obtaining
#             a copy of this software and associated documentation files (the
#             "Software"), to deal in the Software without restriction, including
#             without limitation the rights to use, copy, modify, merge, publish,
#             distribute, sublicense, and/or sell copies of the Software, and to
#             permit persons to whom the Software is furnished to do so, subject
#             to the following conditions:
#
#             The above copyright notice and this permission notice shall be included
#             in all copies or substantial portions of the Software.
#
#             THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#             EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#             MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#             IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#             CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#             TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#             SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
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
      validates_presence_of :calculation_id, :label
      before_save :initialize_units

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
        sub_hash[:value] = Float(value) rescue value
        sub_hash[:unit] = Unit.for(unit) if unit
        sub_hash[:per_unit] = Unit.for(per_unit) if per_unit
        { label.to_sym => sub_hash }
      end

      private

      # Serialize all unit attributes using the string provided by the
      # <tt>label</tt> attribute of a <i>Quantify::Unit::Base</i> object
      #
      def initialize_units
        self.unit = unit.label if unit
        self.per_unit = per_unit.label if per_unit
      end

    end
  end
end
