
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
# :title: Module AMEE::DataAbstraction::PersistenceSupport

module AMEE
  module DataAbstraction

    # This module provides a number of class and instance methods which are
    # added to the <i>AMEE::DataAbstraction::OngoingCalculation</i> class if
    # the amee-data-persistence gem is required. These methods provide an
    # interface between the <i>AMEE::DataAbstraction::OngoingCalculation</i>
    # class (and its instances) and the the <i>AMEE::Db::Calculation</i> class
    # which provides database persistence for calculations.
    #
    module PersistenceSupport

      def self.included(base)
        base.extend ClassMethods
      end

      # Represents the instance of <i>AMEE::Db::Calculation</i> which is
      # associated with <tt>self</tt>.
      #
      attr_accessor :db_calculation

      # Represents the primary key of the associated database record (instance of
      # <i>AMEE::Db::Calculation</i>) if a database record for <tt>self</tt> is
      # defined.
      #
      def id
        db_calculation.nil? ? nil : db_calculation.id
      end

      # Same as <i>save</i> but raises an exception on error
      def save!
        validate!
        record = db_calculation || get_db_calculation
        record.update_calculation!(to_hash)
      end

      # Saves a representation of <tt>self<tt> to the database. Returns
      # <tt>true</tt> if successful, otherwise <tt>false</tt>.
      #
      def save
        save!
        true
      rescue ActiveRecord::RecordNotSaved
        false
      end

      # Deletes the database record for <tt>self</tt> and any associated profile
      # item value in the AMEE platform.
      #
      def delete
        record = db_calculation || get_db_calculation
        AMEE::Db::Calculation.delete record.id
        self.db_calculation = nil
        delete_profile_item
      end

      # As <i>calculate_and_save</i> but raises an exception on error
      def calculate_and_save!
        calculate!
        save!
      end
      
      # Performs the calculation against AMEE and saves it to the database
      def calculate_and_save
        calculate_and_save!
        true
      rescue ActiveRecord::RecordNotFound, AMEE::DataAbstraction::Exceptions::DidNotCreateProfileItem
        false
      end

      # Finds the instance of database record associated with <tt>self</tt> based
      # on the <tt>profile_item_uid</tt> attribute of <tt>self</tt> and sets the
      # <tt>db_calculation</tt> attribute of <tt>self</tt> to the associated
      # instance of <i>AMEE::Db::Calculation</i>.
      #
      def get_db_calculation
        self.db_calculation = AMEE::Db::Calculation.find_or_initialize_by_profile_item_uid(send :profile_item_uid)
      end

      # Returns the subset of terms associated with <tt>self</tt> which should be
      # passed for database persistence, based on the configuration set in
      # <i>AMEE::Db::Config#storage_method</i>.
      #
      def stored_terms
        stored_terms = []
        stored_terms += metadata if OngoingCalculation.store_metadata?
        stored_terms += inputs if OngoingCalculation.store_inputs?
        stored_terms += outputs if OngoingCalculation.store_outputs?
        stored_terms
      end

      # Returns a hash representation of <tt>self</tt>. By default, only the terms
      # which are configured for persistence (according to
      # <i>AMEE::Db::Config#storage_method</i>) are included. All terms can be
      # explicitly required by passing the symbol <tt>:full</tt> as an argument.
      # E.g.
      #
      #   # Set storage to include everything
      #   AMEE::Db::Config.storage_method=:everything
      #
      #   my_calculation.to_hash       #=> { :calculation_type => :fuel,
      #                                      :profile_item_uid => nil,
      #                                      :profile_uid => "A8D8R95EE7DH",
      #                                      :type => { :value => 'coal'},
      #                                      :location => { :value => 'facility' },
      #                                      :mass => { :value => 250,
      #                                                 :unit => <Quantify::Unit ... > },
      #                                      :co2 => { :value => 60.5,
      #                                                :unit => <Quantify::Unit ... > }}
      #
      #   # Set storage to include only oputputs and metadata
      #   AMEE::Db::Config.storage_method=:outputs
      #
      #   my_calculation.to_hash       #=> { :calculation_type => :fuel,
      #                                      :profile_item_uid => nil,
      #                                      :profile_uid => "A8D8R95EE7DH",
      #                                      :location => { :value => 'facility' },
      #                                      :co2 => { :value => 60.5,
      #                                                :unit => <Quantify::Unit ... > }}
      #
      #   # Set storage to include only metadata
      #   AMEE::Db::Config.storage_method=:metadata
      #
      #   my_calculation.to_hash       #=> { :calculation_type => :fuel,
      #                                      :profile_item_uid => nil,
      #                                      :profile_uid => "A8D8R95EE7DH",
      #                                      :location => { :value => 'facility' },
      #
      #   # Get full hash represenation regardless of storage level
      #   my_calculation.to_hash :full #=> { :calculation_type => :fuel,
      #                                      :profile_item_uid => nil,
      #                                      :profile_uid => "A8D8R95EE7DH",
      #                                      :type => { :value => 'coal'},
      #                                      :location => { :value => 'facility' },
      #                                      :mass => { :value => 250,
      #                                                 :unit => <Quantify::Unit ... > },
      #                                      :co2 => { :value => 60.5,
      #                                                :unit => <Quantify::Unit ... > }}
      #
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


        # Find and initialize instance(s) of <i>OngoingCalculation</i> from the
        # database using standard <i>ActiveRecord</i> <tt>find</tt> options.
        # Returns <tt>nil</tt> if no records are found. If multiple records are
        # found they are returned via an instance of the
        # <i>CalculationCollection</i> class. E.g.,
        #
        #   OngoingCalculation.find(:first)
        #
        #                    #=> <AMEE::DataAbstraction::OngoingCalculation ... >
        #
        #  OngoingCalculation.find(:first,
        #                          :conditions => {:profile_item_uid => "K588DH47SMN5"})
        #
        #                    #=> <AMEE::DataAbstraction::OngoingCalculation ... >
        #
        #   OngoingCalculation.find(:all)
        #
        #                    #=> <AMEE::DataAbstraction::CalculationCollection ... >
        #
        def find(*args)
          unless args.last.is_a? Symbol or args.last.is_a? Integer
            raise ActiveRecord::ActiveRecordError.new("Using :include with terms and then conditioning on terms doesn't work due to rails caching.  Use the :joins option instead.") if args.last[:include].to_s.match(/terms/) && args.last[:conditions].to_s.match(/terms/)
            args.last[:include] = "terms" if args.last[:joins].to_s.match(/terms/)
          end
          result = AMEE::Db::Calculation.find(*args)
          return nil unless result
          if result.respond_to?(:map)
            CalculationCollection.new(result.compact.map { |calc| initialize_from_db_record(calc) })
          else
            initialize_from_db_record(result)
          end
        end

        # Find calculations of type  <tt>type</tt> in the database and initialize
        # as instances of <i>OngoingCalculation</i>. Returns <tt>nil</tt> if no
        # records are found. If multiple records are found they are returned via
        # an instance of the <i>CalculationCollection</i> class.
        #
        # Specify that either the first or all records should be returns by passing
        # <tt>:first</tt> or <tt>:all</tt> as the first argument. The unique label
        # of the calcualtion type required should be passed as the second argument.
        # Standard options associated with the <i>ActiveRecord</i> <tt>find</tt>
        # class method can be passed as the third argument. E.g.,
        #
        #   OngoingCalculation.find_by_type(:first,:electricity)
        #
        #                    #=> <AMEE::DataAbstraction::OngoingCalculation ... >
        #
        #   OngoingCalculation.find_by_type(:all,:fuel)
        #
        #                    #=> <AMEE::DataAbstraction::CalculationCollection ... >
        #
        def find_by_type(ordinality,type,options={})
          OngoingCalculation.find(ordinality, options.merge(:conditions => {:calculation_type => type.to_s}))
        end

        # Initialize and return an instance of <i>OngoingCalculation</i> based
        # on the database record represented by <tt>record</tt>.
        #
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

        # Returns a new instance of the <i>AMEE::Db::BaseConfig</i> class
        def storage_config
          AMEE::Db::BaseConfig.new
        end

        # Returns the currently configured storage level for database persistence,
        # i.e. whether all terms should be persisted versus outputs and/or
        # metadata only.
        #
        def storage_method
          storage_config.storage_method
        end

        # Returns <tt>true</tt> if all terms should be persisted within the
        # database according to the currently configured storage level (See
        # <i>AMEE::Db::BaseConfig</i>). Otherwise, returns <tt>false</tt>.
        #
        def store_inputs?
          storage_config.store_everything?
        end

        # Returns <tt>true</tt> if output terms should be persisted within the
        # database according to the currently configured storage level (See
        # <i>AMEE::Db::BaseConfig</i>). Otherwise, returns <tt>false</tt>.
        #
        def store_outputs?
          storage_config.store_outputs?
        end

        # Returns <tt>true</tt> if metadata terms should be persisted within the
        # database according to the currently configured storage level (See
        # <i>AMEE::Db::BaseConfig</i>). Otherwise, returns <tt>false</tt>.
        #
        def store_metadata?
          storage_config.store_metadata?
        end

      end

    end
  end
end