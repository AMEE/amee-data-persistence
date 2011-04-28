require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

include AMEE::Db

describe Calculation do

  valid_calculation_attributes = { :profile_item_uid => "G8T8E8SHSH46",
                                   :calculation_type => :electricity }

  after(:all) do
    Calculation.delete_all
  end

  describe "new calculation" do

    before(:all) do
      @attr = valid_calculation_attributes
    end

    it "should be valid with profile item uid and calculation type" do
      @calculation = Calculation.new @attr
      @calculation.should be_valid
    end

    it "should be valid without profile item uid" do
      @calculation = Calculation.new @attr.merge(:profile_item_uid => "")
      @calculation.should be_valid
    end

    it "should not be valid without calculation type" do
      @calculation = Calculation.new @attr.merge(:calculation_type => "")
      @calculation.should_not be_valid
    end

    it "should be valid with profile uid additionally specified" do
      @calculation = Calculation.new @attr.merge(:profile_uid => "GFD8E8SHSH46")
      @calculation.should be_valid
    end

    it "should not be valid with non-canonical (short) profile item uid" do
      @calculation = Calculation.new @attr.merge(:profile_item_uid => "GFD8E8SHS")
      @calculation.should_not be_valid
    end

    it "should not be valid with non-canonical (lowercase) profile item uid" do
      @calculation = Calculation.new @attr.merge(:profile_item_uid => "gfd8e8shsh46")
      @calculation.should_not be_valid
    end

    it "should not be valid with non-canonical (short) profile uid" do
      @calculation = Calculation.new @attr.merge(:profile_uid => "GFD8E8SHS")
      @calculation.should_not be_valid
    end

    it "should not be valid with non-canonical (lowercase) profile uid" do
      @calculation = Calculation.new @attr.merge(:profile_uid => "gfd8e8shsh46")
      @calculation.should_not be_valid
    end

    it "should not be valid with non-canonical (invalid characters) profile uid" do
      @calculation = Calculation.new @attr.merge(:profile_uid => "gfd8&sh*h4.")
      @calculation.should_not be_valid
    end

    it "should create a new calculation" do
      @calculation = Calculation.create @attr
      @calculation.is_a?(Calculation).should be_true
    end

    it "should save calculation type as string" do
      @calculation = Calculation.create! @attr
      @calculation.reload
      @calculation.calculation_type.should == 'electricity'
      @calculation.calculation_type.class.should == String
      @calculation.type.should == :electricity
      @calculation.type.class.should == Symbol
    end

  end

  describe "updating calculation" do

    valid_term_attributes = { :country => {:value => 'Argentina'},
                              :usage => {:value => 500, :unit => Unit.kWh},
                              :co2 => {:value => 1234.5, :unit => Unit.kg} }

    before(:each) do
      @calculation = Calculation.create valid_calculation_attributes
    end

    it "should update primary attributes" do
      @calculation.profile_item_uid.should == "G8T8E8SHSH46"
      @calculation.profile_uid.should == nil
      @calculation.update_calculation!(:profile_uid => "ASD603SHSHFD", :profile_item_uid => "ASN603DHSREW")
      @calculation.profile_item_uid.should == "ASN603DHSREW"
      @calculation.profile_uid.should == "ASD603SHSHFD"
    end

    it "should not matter which order attributes updated" do
      @calculation.profile_item_uid.should == "G8T8E8SHSH46"
      @calculation.update_calculation!(:profile_uid => "ASD603SHSHFD",
                                       :calculation_type => :energy,
                                       :profile_item_uid => "ASN603DHSREW")
      @calculation.profile_item_uid.should == "ASN603DHSREW"
      @calculation.profile_uid.should == "ASD603SHSHFD"
      @calculation.type.should == :energy
      @calculation.update_calculation!(:profile_uid => nil,
                                       :profile_item_uid => "ASN603DHSREW",
                                       :calculation_type => :electricity)
      @calculation.profile_item_uid.should == "ASN603DHSREW"
      @calculation.profile_uid.should == nil
      @calculation.type.should == :electricity
    end

    it "should allow removal of profile item uid" do
      @calculation.profile_item_uid.should == "G8T8E8SHSH46"
      @calculation.profile_uid.should == nil
      @calculation.update_calculation!(:profile_uid => "ASD603SHSHFD", :profile_item_uid => nil)
      @calculation.profile_item_uid.should == nil
    end

    it "should update associated terms" do
      @calculation.to_hash.should == { :profile_item_uid => "G8T8E8SHSH46",
                                       :profile_uid => nil }
      @calculation.type.should == :electricity
      @calculation.update_calculation! valid_term_attributes.merge :calculation_type => :power
      hash = @calculation.to_hash
      hash.keys.map!(&:to_s).sort!.should == [ :profile_item_uid, :usage, :co2, :country,
                                               :profile_uid].map!(&:to_s).sort!
      hash[:co2][:unit].should be_a Quantify::Unit::SI
      hash[:co2][:value].should eql "1234.5"
      hash[:co2][:unit].name.should eql 'kilogram'
      hash[:usage][:unit].should be_a Quantify::Unit::NonSI
      hash[:usage][:value].should eql "500"
      hash[:usage][:unit].name.should eql 'kilowatt hour'
      hash[:country][:value].should eql 'Argentina'
      @calculation.calculation_type.should eql 'power'
      @calculation.type.should eql :power
      @calculation.update_calculation! valid_term_attributes.merge :calculation_type => :electricity
      @calculation.calculation_type.should eql 'electricity'
      @calculation.type.should eql :electricity
    end

    it "should update associated terms, removing unspecified terms" do
      @calculation.to_hash.should == { :profile_item_uid => "G8T8E8SHSH46",
                                       :profile_uid => nil }
      @calculation.type.should == :electricity
      @calculation.update_calculation! valid_term_attributes
      hash = @calculation.to_hash
      hash.keys.map!(&:to_s).sort!.should == [:profile_item_uid, :usage, :co2, :country,
                                              :profile_uid ].map!(&:to_s).sort!
      @calculation.type.should == :electricity
      @calculation.update_calculation! :usage => {:value => 600000, :unit => Unit.kWh}, :country => {:value =>'Argentina'}
      hash = @calculation.to_hash
      hash.keys.map!(&:to_s).sort!.should == [ :profile_item_uid, :usage, :country,
                                              :profile_uid ].map!(&:to_s).sort!
      hash[:co2].should be_a NilClass
      hash[:usage][:unit].should be_a Quantify::Unit::NonSI
      hash[:usage][:value].should == "600000"
      hash[:usage][:unit].name.should == 'kilowatt hour'
      hash[:country][:value].should == 'Argentina'
      @calculation.type.should == :electricity
    end

    it "should find by atttribute" do
      calc = Calculation.find :first, :conditions => {:calculation_type => 'electricity'}
      calc.class.should == Calculation
      calc.type.should == :electricity
    end

  end

  
  
end

