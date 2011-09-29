# Copyright (C) 2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

# :title: Class: AMEE::Db::Calculation

module AMEE
  module Db

    # This class represents a database record for a calculation performed using
    # the <i>AMEE:DataAbstraction::OngoingCalculation</i> class. This class stores
    # the primary calculation level attributes such as the calculation
    # <tt>calculation_type</tt>, <tt>profile_uid</tt> and <tt>profile_item_uid</tt>.
    #
    # The values and attributes of specific calculation terms are stored via the
    # related class <i>AMEE::Db::Term</i>.
    #
    # This class is typically used by proxy, via the <tt>find</tt>,
    # <tt>find_by_type</tt>, <tt>#save</tt>, <tt>#delete</tt>, and
    # <tt>#get_db_calculation</tt> methods associated with the
    # <i>AMEE:DataAbstraction::OngoingCalculation</i> class.
    #
    class Calculation < ActiveRecord::Base

      has_many              :terms, :class_name => "AMEE::Db::Term", :dependent => :destroy
      validates             :calculation_type, :presence => true
      validates             :profile_item_uid, :format => {:with => /\A([A-Z0-9]{12})\z/, :allow_nil => true, :allow_blank => true}
      validates             :profile_uid, :format => {:with => /\A([A-Z0-9]{12})\z/, :allow_nil => true, :allow_blank => true}
      before_save           :validate_calculation_type

      # Standardize the <tt>calculation_type</tt> attribute to <i>String</i>
      # format. Called using before filter prior to record saving to ensure
      # string serialization.
      #
      def validate_calculation_type
        self.calculation_type = calculation_type.to_s
      end

      # Convenience method for returning the <tt>calculation_type</tt> attribute
      # of <tt>self</tt> in canonical symbol form.
      #
      def type
        calculation_type.to_sym
      end

      # Returns the subset of all instance attributes which should be editable via
      # mass update methods and which should be included in hash representations of
      # self, i.e. those passed in explcitly as data rather than added by
      # <i>ActiveRecord</i> (e.g. <tt>id</tt>, <tt>created_at</tt>, etc.).
      #
      def primary_calculation_attributes
        attributes.keys.reject {|attr| ['id','created_at','updated_at'].include? attr }
      end

      # Update the attributes of <tt>self</tt> and those of any related terms,
      # according to the passed <tt>options</tt> hash. Any associated terms which
      # are not represented in <tt>options</tt> are deleted.
      #
      # Term attributes provided in <tt>options</tt> should be keyed with the
      # term label and include a sub-hash with keys represent one or more of
      # :value, :unit and :per_unit. E.g.,
      #
      #   options = { :profile_item_uid => "W93UEY573U4E8",
      #               :mass => { :value => 23 },
      #               :distance => { :value => 1400,
      #                              :unit => <Quantify::Unit::SI ... > }}
      #
      #   my_calculation.update_calculation!(options)
      #
      def update_calculation!(options)
        primary_calculation_attributes.each do |attr|
          if options.keys.include? attr.to_sym
            update_calculation_attribute!(attr,options.delete(attr.to_sym),false)
          end
        end
        save!
        options.each_pair do |attribute,value|
          add_or_update_term!(attribute,value)
        end
        delete_unspecified_terms(options)
        reload
      end

      # Update the attribute of <tt>self</tt> represented by the label
      # <tt>key</tt> with the value of <tt>value</tt>. By default,
      # the <tt>#save!</tt> method is called, in turn calling the class
      # validations.
      #
      # Specify that the record should not be saved by passing <tt>false</tt>
      # as the final argument.
      #
      def update_calculation_attribute!(key,value,save=true)
        # use attr_accessor (via #send) method rather than
        # #update_attribute so that validations are performed
        #
        send("#{key}=", (value.nil? ? nil : value.to_s))
        save! if save
      end

      # Add, or update an existing, associated term represented by the label
      # <tt>label</tt> and value, unit and/or per_unit attributes defined by
      # <tt>data</tt>. The <tt>data</tt> argument should be a hash with keys
      # represent one or more of :value, :unit and :per_unit. E.g.,
      #
      #   data = {  :value => 1400,
      #            :unit => <Quantify::Unit::SI ... > }
      #
      #   my_calculation.add_or_update_term!(:distance, data)
      #
      # This method is called as part of the <tt>#update_calculation!</tt>
      # method
      #
      def add_or_update_term!(label,data)
        term = Term.find_or_initialize_by_calculation_id_and_label(id,label.to_s)
        term.update_attributes!(data)
      end

      # Delete all of the terms which are not explicitly referenced in the
      # <tt>options</tt> hash.
      #
      # This method is called as part of the <tt>#update_calculation!</tt>
      # method
      #
      def delete_unspecified_terms(options)
        terms.each do |term|
          Term.delete(term.id) unless options.keys.include? term.label.to_sym
        end
      end

      # Returns a <i>Hash</i> representation of <tt>self</tt> including a only
      # the data explicitly passed in (those added by <i>ActiveRecord</i> -
      # <tt>created</tt>, <tt>updated</tt>, <tt>id</tt> - are ignored) as well
      # as sub-hashes for all associated terms. E.g.,
      #
      #   my_calculation.to_hash       #=> { :profile_uid => "EYR758EY36WY",
      #                                      :profile_item_uid => "W83URT48DY3W",
      #                                      :type => { :value => 'car' },
      #                                      :distance => { :value => 1600,
      #                                                     :unit => <Quantify::Unit::SI> },
      #                                      :co2 => { :value => 234.1,
      #                                                :unit => <Quantify::Unit::NonSI> }}
      #
      # This method can be used to initialize instances of the class
      # <tt>OngoingCalculation</tt> by providing the hashed options for any of 
      # the <tt>choose...</tt> methods.
      #
      def to_hash
        hash = {}
        terms.each { |term| hash.merge!(term.to_hash) }
        [ :profile_item_uid, :profile_uid ].each do |attr|
          hash[attr] = self.send(attr)
        end
        return hash
      end
    end
  end
end
