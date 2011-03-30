module AMEE
  module Db
    class Calculation < ActiveRecord::Base

      has_many :terms, :class_name => "AMEE::Db::Term", :dependent => :destroy
      validates_presence_of :calculation_type
      validates_format_of   :profile_item_uid, :with => /\A([A-Z0-9]{12})\z/, :allow_nil => true, :allow_blank => true
      validates_format_of   :profile_uid, :with => /\A([A-Z0-9]{12})\z/, :allow_nil => true, :allow_blank => true

      # Bespoke update method handling both attributes of self and associated
      # terms
      def update_calculation!(options)
        calculation_attributes.keys.each do |attr|
          if options.keys.include? attr.to_sym
            update_calculation_attribute!(attr,options.delete(attr.to_sym))
          end
        end
        options.each_pair do |attribute,value|
          add_or_update_term!(attribute,value)
        end
        delete_unspecified_terms(options)
        reload
      end

      # Convenience method for accessing calculation type as the canonical symbol
      def type
        calculation_type.to_sym
      end

      # Returns the subset of all instance attributes which represent those passed
      # explcitly in as data, i.e. removes those added by ActiveRecord
      #
      def calculation_attributes
        attributes.reject {|attr,value| ['id','created_at','updated_at'].include? attr }
      end

      # Determine if a given symbol corresponds to one of the calcualtion attributes
      def is_calculation_attribute?(symbol)
        calculation_attributes.keys.map(&:to_sym).include?(symbol)
      end

      # use attr_accessor (via #send) method rather than #update_attribute so that
      # validations are performed
      def update_calculation_attribute!(key,value)
        send("#{key}=", (value.nil? ? nil : value.to_s))
        save!
      end

      def add_or_update_term!(label,value)
        term = Term.find_or_initialize_by_calculation_id_and_label(id,label.to_s)
        term.update_value!(value)
      end

      def delete_unspecified_terms(options)
        terms.each do |term|
          Term.delete(term.id) unless options.keys.include? term.label.to_sym
        end
      end

      # Covert record to hash. Only the data explicitly passed in are included, i.e.
      # those added by ActiveRecord (created, updated, id) are ignored.
      #
      # Always return calculation_type as a symbol
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
