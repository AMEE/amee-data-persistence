require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

include AMEE::Db

describe Term do

  before(:all) do
    ActiveRecord::Base.establish_connection(DB_CONFIG)
    ActiveRecord::Migrator.up(DB_MIGRATION)
  end

  describe "new term" do

    valid_term_attributes = { :label => 'type',
                              :value => 'petrol',
                              :calculation_id => '1' }
    before(:all) do
      @attr = valid_term_attributes
    end

    it "should be valid with label, value and calcualtion id" do
      @term = Term.new @attr
      @term.should be_valid
    end

    it "should be invalid without label" do
      @term = Term.new @attr.merge(:label => nil)
      @term.should_not be_valid
    end

    it "should be invalid without value" do
      @term = Term.new @attr.merge(:value => nil)
      @term.should_not be_valid
    end

    it "should be invalid without calculation id" do
      @term = Term.new @attr.merge(:calculation_id => nil)
      @term.should_not be_valid
    end

    it "should create a new term" do
      @term = Term.create @attr
      @term.is_a?(Term).should be_true
    end

    it "should create a new term from quantity onject" do
      @term = Term.create @attr.merge :value => 25.metres
      @term.is_a?(Term).should be_true
      @term.value.should == '25.0 m'
    end

    it "should return attribute" do
      @term = Term.create @attr
      @term.value.should == 'petrol'
    end

  end

  describe "quantity objects in value attribute" do

    valid_term_attributes = { :label => 'co2',
                              :value => nil,
                              :calculation_id => '1' }
    before(:all) do
      @attr = valid_term_attributes
    end

    it "should be converted to string" do
      @term = Term.create @attr.merge :value => 25.3.kg
      @term.value.should == '25.3 kg'
    end

    it "should be converted to string" do
      @term = Term.create @attr.merge :value => 10000.Gg
      @term.value.should == '10000.0 Gg'
    end

    it "should be converted to string" do
      @term = Term.create @attr.merge :value => 6000.kWh
      @term.value.should == '6000.0 kWh'
    end

    it "should be converted to string with compound unit label" do
      @term = Term.create @attr.merge :value => (Quantity.new 6000, Unit.kg/(Unit.t*Unit.km))
      @term.value.should == '6000.0 kg/t·km'
    end
  end

  describe "updating value attribute" do
    valid_term_attributes = { :label => 'co2',
                              :value => '1.2345 kg',
                              :calculation_id => '1' }
    before(:each) do
      @term = Term.new(valid_term_attributes)
      @term.update_value! @term.value
    end

    it "should update value via new quantity object" do
      @term.value.should == "1.2345 kg"
      @term.update_value! 543.kg
      @term.value.should == "543.0 kg"
    end

    it "should update value via new quantity object" do
      @term.value.should == "1.2345 kg"
      @term.update_value! 1.2345.kg.to_pounds
      @term.value.should == "2.72160662667231 lb"
    end

    it "should update value via new quantity object" do
      @term.value.should == "1.2345 kg"
      co2_density = Quantity.new 1.977, Unit.kg/Unit.cubic_metre
      @term.update_value! 1.2345.kg/co2_density
      @term.value.should == "0.62443095599393 m^3"
    end

    it "should update value with simple value" do
      @term.value.should == "1.2345 kg"
      @term.update_value! 1.2345
      @term.value.should == "1.2345"
    end

    it "should update value with plain string" do
      @term.value.should == "1.2345 kg"
      @term.update_value! "some string"
      @term.value.should == "some string"
    end
  end

  describe "values" do

    valid_term_attributes = { :label => 'co2',
                              :value => '1.2345 kg',
                              :calculation_id => '1' }
    before(:all) do
      @attr = valid_term_attributes
    end

    it "should be converted to quantity object if representing a quantity" do
      @term = Term.create @attr
      quantity = @term.value_or_quantity_object
      quantity.class.should == Quantity
      quantity.value.should == 1.2345
      quantity.unit.name.should == 'kilogram'
    end

    it "should be converted to quantity object if representing a quantity" do
      @term = Term.create @attr.merge :value => "100 m^3"
      quantity = @term.value_or_quantity_object
      quantity.class.should == Quantity
      quantity.value.should == 100
      quantity.unit.name.should == 'cubic metre'
    end

    it "should be converted to quantity object if representing a quantity" do
      @term = Term.create @attr.merge :value => "0.5 gal"
      quantity = @term.value_or_quantity_object
      quantity.class.should == Quantity
      quantity.value.should == 0.5
      quantity.unit.name.should == 'us liquid gallon'
    end

    it "should be converted to quantity object if representing a quantity with compound unit " do
      @term = Term.create @attr.merge :value => "0.5 kg/t·km"
      quantity = @term.value_or_quantity_object
      quantity.class.should == Quantity
      quantity.value.should == 0.5
      quantity.unit.name.should == 'kilogram per tonne kilometre'
    end

    it "should return plain value if not representative of a quantity" do
      @term = Term.create @attr.merge :value => '1.2345'
      @term.value_or_quantity_object.should == '1.2345'
    end

    it "should return plain value if not a known unit" do
      @term = Term.create @attr.merge :value => '1.2345 kilolumps'
      @term.value_or_quantity_object.should == '1.2345 kilolumps'
    end

    it "should return plain value if not representative of a quantity" do
      @term = Term.create @attr.merge :value => 'some non quantity string'
      @term.value_or_quantity_object.should == 'some non quantity string'
    end

  end

  describe "hash representation" do

    valid_term_attributes = { :label => 'co2',
                              :value => '1.2345 kg',
                              :calculation_id => '1' }
    before(:all) do
      @term = Term.create valid_term_attributes
    end

    it "should convert record to hash with quantity object" do
      hash = @term.to_hash.to_a.flatten
      hash.first.should == :co2
      hash.last.class.should == Quantity
      hash.last.value.should == 1.2345
      hash.last.unit.symbol.should == 'kg'
    end

    it "should convert record to hash with quantity object" do
      @term.update_value! 500.lb
      @term.value.should == "500.0 lb"
      hash = @term.to_hash.to_a.flatten
      hash.first.should == :co2
      hash.last.class.should == Quantity
      hash.last.value.should == 500
      hash.last.unit.symbol.should == 'lb'
    end

    it "should convert record to hash with quantity object" do
      @term.update_value! 10000.litres
      @term.value.should == "10000.0 L"
      hash = @term.to_hash.to_a.flatten
      hash.first.should == :co2
      hash.last.class.should == Quantity
      hash.last.value.should == 10000
      hash.last.unit.symbol.should == 'L'
    end

    it "should convert record to hash with quantity object and compound unit" do
      @term.update_value! Quantity.new 10, Unit.kg/(Unit.t*Unit.km)
      @term.value.should == "10.0 kg/t·km"
      hash = @term.to_hash.to_a.flatten
      hash.first.should == :co2
      hash.last.class.should == Quantity
      hash.last.value.should == 10
      hash.last.unit.symbol.should == 'kg t^-1 km^-1'
    end

    it "should convert record to hash with plain value" do
      @term.update_value! 100
      @term.value.should == "100"
      hash = @term.to_hash.to_a.flatten
      hash.first.should == :co2
      hash.last.class.should == String
      hash.last.should == '100'
    end

    it "should convert record to hash with plain value" do
      @term.update_value! "astring"
      @term.value.should == "astring"
      hash = @term.to_hash.to_a.flatten
      hash.first.should == :co2
      hash.last.class.should == String
      hash.last.should == 'astring'
    end

  end

  
end