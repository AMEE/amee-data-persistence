module AMEE
  module Db
    class Calculation < ActiveRecord::Base

      has_many              :terms, :class_name => "AMEE::Db::Term", :dependent => :destroy
      validates_presence_of :calculation_type
      validates_format_of   :profile_item_uid, :with => /\A([A-Z0-9]{12})\z/, :allow_nil => true, :allow_blank => true
      validates_format_of   :profile_uid, :with => /\A([A-Z0-9]{12})\z/, :allow_nil => true, :allow_blank => true
      before_save           :validate_calculation_type

      # This is required as ActiveRecord seemingly cannot handle symbols correctly.
      # Calculation types are therefore stored as strings. Symbol representations
      # are conveniently provided by the #type method below
      #
      def validate_calculation_type
        self.calculation_type = calculation_type.to_s
      end

      # Convenience method for accessing calculation type as the canonical symbol
      def type
        calculation_type.to_sym
      end

      # Returns the subset of all instance attributes which should be editable via
      # mass update methods and which should be included in hash representations of
      # self, i.e. those passed in explcitly as data rather than added by
      # ActiveRecord
      #
      def primary_calculation_attributes
        attributes.keys.reject {|attr| ['id','created_at','updated_at'].include? attr }
      end

      # Bespoke update method handling both attributes of self and associated
      # terms
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

      # use attr_accessor (via #send) method rather than #update_attribute so that
      # validations are performed
      def update_calculation_attribute!(key,value,save=true)
        send("#{key}=", (value.nil? ? nil : value.to_s))
        save! if save
      end

      def add_or_update_term!(label,data)
        term = Term.find_or_initialize_by_calculation_id_and_label(id,label.to_s)
        term.update_attributes!(data)
      end

      def delete_unspecified_terms(options)
        terms.each do |term|
          Term.delete(term.id) unless options.keys.include? term.label.to_sym
        end
      end

      # Covert record to hash. Only the data explicitly passed in are included, i.e.
      # those added by ActiveRecord (created, updated, id) are ignored.
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
