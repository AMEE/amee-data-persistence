require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

include AMEE::Db

describe Term do

  before(:all) do
    Calculation.create :calculation_type => :electricity
  end

  after(:all) do
    Calculation.delete_all
    Term.delete_all
  end

  describe "new term" do

    valid_term_attributes = { :label => 'co2',
                              :value => 120,
                              :unit => Unit.kg,
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

    it "should be valid without value" do
      @term = Term.new @attr.merge(:value => nil)
      @term.should be_valid
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
      @term = Term.create @attr.merge :per_unit => Unit.km
      @term.is_a?(Term).should be_true
      @term.value.should == 120
      @term.unit.should == 'kg'
      @term.per_unit.should == 'km'
    end

    it "should return attribute" do
      @term = Term.create @attr
      @term.value.should == 120
    end

  end

  describe "units" do

    valid_term_attributes = { :label => 'co2',
                              :value => nil,
                              :unit => Unit.kg,
                              :per_unit => Unit.year,
                              :calculation_id => '1' }
    before(:all) do
      @attr = valid_term_attributes
    end

    it "should be converted to string with JScience label" do
      @term = Term.create @attr.merge :value => 25.3
      @term.value.should == 25.3
      @term.unit.should == 'kg'
    end

    it "should be converted to string with JScience label" do
      @term = Term.create @attr.merge :unit => Unit.short_ton
      @term.unit.should == 'ton_us'
    end
  end

  describe "hash representation" do

    valid_term_attributes = { :label => 'co2',
                              :value => nil,
                              :unit => Unit.kg,
                              :per_unit => Unit.year,
                              :calculation_id => '1' }
    before(:all) do
      @term = Term.create valid_term_attributes
    end

    it "should convert record to hash with quantity objects" do
      hash = @term.to_hash
      hash.keys.should eql [:co2]
      hash[:co2][:value].should be_nil
      hash[:co2][:unit].should be_a Quantify::Unit::Base
      hash[:co2][:unit].name.should eql 'kilogram'
      hash[:co2][:per_unit].should be_a Quantify::Unit::Base
      hash[:co2][:per_unit].name.should eql 'year'
    end

  end

  
end