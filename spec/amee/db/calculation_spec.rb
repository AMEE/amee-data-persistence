require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

include AMEE::Db

describe Calculation do

  valid_calculation_attributes = { :profile_item_uid => "G8T8E8SHSH46",
                                   :calculation_type => :cement }
  
  before(:all) do
    ActiveRecord::Base.establish_connection(DB_CONFIG)
    ActiveRecord::Migrator.up(DB_MIGRATION)
  end

  describe "new calculation" do

    before(:all) do
      @attr = valid_calculation_attributes
    end

    it "should be valid with profile item uid and calculation type" do
      @calculation = Calculation.new @attr
      @calculation.should be_valid
    end

    it "should not be valid without profile item uid" do
      @calculation = Calculation.new @attr.merge(:profile_item_uid => "")
      @calculation.should_not be_valid
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

    it "should return attribute" do
      @calculation = Calculation.create @attr
      @calculation.calculation_type.should == :cement
    end

  end

  describe "updating calculation" do

    valid_term_attributes = { :type => 'limestone',
                              :process => 'calcination',
                              :mass => '500 t',
                              :co2 => "1234.5 kg",
                              :ch4 => "12.3 kg",
                              :section => 'facility' }

    before(:each) do
      @calculation = Calculation.create valid_calculation_attributes
    end

    it "should update primary attributes" do
      @calculation.profile_item_uid.should == "G8T8E8SHSH46"
      @calculation.profile_uid.should == nil
      @calculation.update_calculation! :profile_uid => "ASD603SHSHFD", :profile_item_uid => "ASN603DHSREW"
      @calculation.profile_item_uid.should == "ASN603DHSREW"
      @calculation.profile_uid.should == "ASD603SHSHFD"
    end

    it "should reject removal of profile item uid" do
      @calculation.profile_item_uid.should == "G8T8E8SHSH46"
      @calculation.profile_uid.should == nil
      lambda{
        @calculation.update_calculation!(
          :profile_uid => "ASD603SHSHFD",
          :profile_item_uid => nil)
        }.should raise_error
    end

    it "should update associated terms" do
      @calculation.to_hash.should == { :profile_item_uid => "G8T8E8SHSH46",
                                       :calculation_type => :cement,
                                       :profile_uid => nil }
      @calculation.update_calculation! valid_term_attributes
      hash = @calculation.to_hash
      hash.keys.map!(&:to_s).sort!.should == [ :type, :process, :profile_item_uid, :mass, :co2, :ch4,
                            :calculation_type, :section, :profile_uid].map!(&:to_s).sort!
      hash[:co2].class.should == Quantity
      hash[:co2].value.should == 1234.5
      hash[:co2].unit.name.should == 'kilogram'
      hash[:ch4].class.should == Quantity
      hash[:ch4].value.should == 12.3
      hash[:ch4].unit.name.should == 'kilogram'
      hash[:mass].class.should == Quantity
      hash[:mass].value.should == 500.0
      hash[:mass].unit.name.should == 'tonne'
      hash[:process].should == 'calcination'
      hash[:type].should == 'limestone'
      hash[:section].should == 'facility'
    end

    it "should update associated terms, removing unspecified terms" do
      @calculation.to_hash.should == { :profile_item_uid => "G8T8E8SHSH46",
                                       :calculation_type => :cement,
                                       :profile_uid => nil }
      @calculation.update_calculation! valid_term_attributes
      hash = @calculation.to_hash
      hash.keys.map!(&:to_s).sort!.should == [ :type, :process, :profile_item_uid, :mass, :co2, :ch4,
                                               :calculation_type, :section, :profile_uid].map!(&:to_s).sort!
      hash[:type].should == 'limestone'
      @calculation.update_calculation! :type => 'dolomite', :process => 'calcination', :section => 'facility'
      hash = @calculation.to_hash
      hash.keys.map!(&:to_s).sort!.should == [ :type, :process, :profile_item_uid,
                                               :calculation_type, :section, :profile_uid].map!(&:to_s).sort!
      hash[:process].should == 'calcination'
      hash[:type].should == 'dolomite'
      hash[:section].should == 'facility'
    end

  end
  
end

