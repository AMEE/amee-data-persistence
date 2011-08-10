require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe AMEE::DataAbstraction::OngoingCalculation do

  before(:all) do
    populate_db
    initialize_calculation_set
  end

  after(:all) do
    AMEE::Db::Calculation.delete_all
  end

  describe "find" do

    before(:each) do
      choose_mock
      yaml_load_mock(:everything)
      @reference = AMEE::Db::Calculation.find(:first).id
    end

    it "should create new ongoing calculation from db record" do
      @db_calculation = AMEE::Db::Calculation.find :first
      @ongoing_calculation = AMEE::DataAbstraction::OngoingCalculation.initialize_from_db_record @db_calculation
      @ongoing_calculation.is_a?(AMEE::DataAbstraction::OngoingCalculation).should be_true
      @ongoing_calculation.label.should == :electricity
      @ongoing_calculation.profile_item_uid.should == "J38DY57SK591"
      @ongoing_calculation.profile_uid.should be_nil
      hash = @ongoing_calculation.to_hash
      hash[:co2][:value].should == 1200
      hash[:country][:value].should == 'Argentina'
      hash[:usage][:value].should == 6000
      hash[:profile_item_uid].should == "J38DY57SK591"
      hash[:profile_uid].should be_nil
    end

    it "should create new ongoing calculation from db record with find" do
      @ongoing_calculation = AMEE::DataAbstraction::OngoingCalculation.find :first
      @ongoing_calculation.is_a?(AMEE::DataAbstraction::OngoingCalculation).should be_true
      @ongoing_calculation.label.should == :electricity
      @ongoing_calculation.profile_item_uid.should == "J38DY57SK591"
      @ongoing_calculation.profile_uid.should be_nil
      hash = @ongoing_calculation.to_hash
      hash[:co2][:value].should == 1200
      hash[:country][:value].should == 'Argentina'
      hash[:usage][:value].should == 6000
      hash[:profile_item_uid].should == "J38DY57SK591"
      hash[:profile_uid].should be_nil
    end
  
    it "should create new ongoing calculation from db record with find and calculation type" do
      @ongoing_calculation = AMEE::DataAbstraction::OngoingCalculation.find :first, :conditions => {:calculation_type => 'electricity'}
      @ongoing_calculation.label.should == :electricity
      @ongoing_calculation.is_a?(AMEE::DataAbstraction::OngoingCalculation).should be_true
      @ongoing_calculation.profile_item_uid.should == "J38DY57SK591"
      @ongoing_calculation.profile_uid.should be_nil
      hash = @ongoing_calculation.to_hash
      hash[:co2][:value].should == 1200
      hash[:country][:value].should == 'Argentina'
      hash[:usage][:value].should == 6000
      hash[:profile_item_uid].should == "J38DY57SK591"
      hash[:profile_uid].should be_nil
    end

    it "should create new ongoing calculation from db record with find and profile item uid" do
      @ongoing_calculation = AMEE::DataAbstraction::OngoingCalculation.find :first, :conditions => {:profile_item_uid => "K588DH47SMN5"}
      @ongoing_calculation.label.should == :electricity
      @ongoing_calculation.is_a?(AMEE::DataAbstraction::OngoingCalculation).should be_true
      @ongoing_calculation.profile_item_uid.should == "K588DH47SMN5"
      @ongoing_calculation.profile_uid.should == "H9KJ49FKIWO5"
      hash = @ongoing_calculation.to_hash
      hash[:co2][:value].should == 1.2
      hash[:country][:value].should == 'Argentina'
      hash[:usage][:value].should == 12345
      hash[:profile_item_uid].should == "K588DH47SMN5"
      hash[:profile_uid].should == "H9KJ49FKIWO5"
    end
  
    it "should create multiple new ongoing calculations from db record with find" do
      @ongoing_calculations = AMEE::DataAbstraction::OngoingCalculation.find :all
      @ongoing_calculations.class.should == AMEE::DataAbstraction::CalculationCollection
      @ongoing_calculations.each do |on_calc|
        on_calc.label.should == :electricity
        on_calc.is_a?(AMEE::DataAbstraction::OngoingCalculation).should be_true
        on_calc.profile_item_uid.should_not be_nil
        hash = on_calc.to_hash
        hash[:co2][:value].should_not be_nil
        hash[:country][:value].should == 'Argentina'
        hash[:usage][:value].should_not be_nil
      end
    end

    it "should create new ongoing calculation from db record with #find_by_type" do
      @ongoing_calculation = AMEE::DataAbstraction::OngoingCalculation.find_by_type :first, :electricity
      @ongoing_calculation.label.should == :electricity
      @ongoing_calculation.is_a?(AMEE::DataAbstraction::OngoingCalculation).should be_true
      @ongoing_calculation.profile_item_uid.should == "J38DY57SK591"
      @ongoing_calculation.profile_uid.should == nil
      hash = @ongoing_calculation.to_hash
      hash[:co2][:value].should == 1200
      hash[:country][:value].should == 'Argentina'
      hash[:usage][:value].should == 6000
      hash[:profile_item_uid].should == "J38DY57SK591"
      hash[:profile_uid].should == nil
    end

    it "should create multiple new ongoing calculations from db record with #find_by_type" do
      @ongoing_calculations = AMEE::DataAbstraction::OngoingCalculation.find_by_type :all, :electricity
      @ongoing_calculations.class.should == AMEE::DataAbstraction::CalculationCollection
      @ongoing_calculations.each do |on_calc|
        on_calc.label.should == :electricity
        on_calc.is_a?(AMEE::DataAbstraction::OngoingCalculation).should be_true
        on_calc.profile_item_uid.should_not be_nil
        hash = on_calc.to_hash
        hash[:co2][:value].should_not be_nil
        hash[:country][:value].should == 'Argentina'
        hash[:usage][:value].should_not be_nil
      end
    end

    it "should instantiate record at ongoing calc #db_calculation attribute" do
      @ongoing_calculation = AMEE::DataAbstraction::OngoingCalculation.find :first
      @ongoing_calculation.label.should == :electricity
      @ongoing_calculation.to_hash[:co2][:value].should == 1200
      @ongoing_calculation.db_calculation.is_a?(AMEE::Db::Calculation).should be_true
      @ongoing_calculation.db_calculation.id.should == @reference
    end

    it "should find assocaited db instance by id" do
      @ongoing_calculation = AMEE::DataAbstraction::OngoingCalculation.find @reference
      @ongoing_calculation.id.should == @reference
    end


    it "should give nil id, if not saved" do
      Calculations[:electricity].begin_calculation.db_calculation.should be_nil
      Calculations[:electricity].begin_calculation.id.should be_nil
    end
  end

  describe "when storage method is :everything" do

    before(:each) do
      choose_mock
      yaml_load_mock(:everything)
      @ongoing_calculation = AMEE::DataAbstraction::OngoingCalculation.find :first
    end

    it "should find storage method" do
      AMEE::DataAbstraction::OngoingCalculation.storage_method.should == :everything
    end

    it "should start off dirty" do
      @ongoing_calculation.should be_dirty
    end

    it "should establish whether inputs to be stored" do
      AMEE::DataAbstraction::OngoingCalculation.store_inputs?.should be_true
    end

    it "should establish whether outputs to be stored" do
      AMEE::DataAbstraction::OngoingCalculation.store_outputs?.should be_true
    end

    it "should establish whether metadata to be stored" do
      AMEE::DataAbstraction::OngoingCalculation.store_metadata?.should be_true
    end

    it "should return array of terms for storing which includes all terms" do
      @ongoing_calculation.stored_terms.should == @ongoing_calculation.terms
    end

    it "should return hash with all terms" do
      hash = @ongoing_calculation.to_hash
      hash.is_a?(Hash).should be_true
      hash.should == @ongoing_calculation.to_hash(:full)
      hash.keys.map!(&:to_s).sort!.should == [:profile_item_uid, :profile_uid, :calculation_type,
                                              :co2, :usage, :country ].map!(&:to_s).sort!
    end

    it "should save all terms" do
      record = @ongoing_calculation.db_calculation
      # show that db record has values
      record.to_hash.keys.map!(&:to_s).sort!.should == [:profile_item_uid, :profile_uid, :co2,
                                                        :usage, :country ].map!(&:to_s).sort!
      record.to_hash[:co2][:value].should == 1200
      record.to_hash[:usage][:value].should == 6000
      # wipe terms from db record by updating with nothing
      record.update_calculation!(options={})
      # show that db record contains no terms
      record.to_hash.keys.map!(&:to_s).sort!.should == [:profile_item_uid, :profile_uid ].map!(&:to_s).sort!
      # show that by saving ongoing calculation, db record has terms
      @ongoing_calculation.save
      record = @ongoing_calculation.db_calculation
      record.to_hash.keys.map!(&:to_s).sort!.should == [:profile_item_uid, :profile_uid, :co2,
                                                        :usage, :country ].map!(&:to_s).sort!
      record.to_hash[:co2][:value].should == 1200
      record.to_hash[:usage][:value].should == 6000
    end

  end

  describe "when storage method is :metadata" do

    before(:each) do
      choose_mock
      yaml_load_mock(:metadata)
      @ongoing_calculation = AMEE::DataAbstraction::OngoingCalculation.find :first
    end

    it "should find storage method" do
      AMEE::DataAbstraction::OngoingCalculation.storage_method.should == :metadata
    end

    it "should establish whether inputs to be stored" do
      AMEE::DataAbstraction::OngoingCalculation.store_inputs?.should be_false
    end

    it "should establish whether outputs to be stored" do
      AMEE::DataAbstraction::OngoingCalculation.store_outputs?.should be_false
    end

    it "should establish whether metadata to be stored" do
      AMEE::DataAbstraction::OngoingCalculation.store_metadata?.should be_true
    end

    it "should start off dirty" do
      @ongoing_calculation.should be_dirty
    end

    it "should return array of terms for storing which includes only metadata" do
      @ongoing_calculation.stored_terms.should_not == @ongoing_calculation.terms
    end

    it "should return hash with only metadata terms" do
      hash = @ongoing_calculation.to_hash
      hash.is_a?(Hash).should be_true
      hash.should_not == @ongoing_calculation.to_hash(:full)
      hash.keys.map!(&:to_s).sort!.should == [:profile_item_uid, :profile_uid,
                                              :calculation_type ].map!(&:to_s).sort!
    end

    it "should save only metadata terms" do
      record = @ongoing_calculation.db_calculation
      # show that db record has values
      record.to_hash.keys.map!(&:to_s).sort!.should == [:profile_item_uid, :profile_uid, :co2,
                                                        :usage, :country ].map!(&:to_s).sort!
      record.to_hash[:co2][:value].should == 1200
      record.to_hash[:usage][:value].should == 6000
      # show that db record contains no terms after save
      @ongoing_calculation.save
      record = @ongoing_calculation.db_calculation
      record.to_hash.keys.map!(&:to_s).sort!.should == [:profile_item_uid, :profile_uid ].map!(&:to_s).sort!
      record.to_hash[:co2].should == nil
      record.to_hash[:usage].should == nil
    end

  end

  describe "when storage method is :outputs" do

    before(:each) do
      choose_mock
      yaml_load_mock(:outputs)
      @ongoing_calculation = AMEE::DataAbstraction::OngoingCalculation.find :first
    end

    it "should find storage method" do
      AMEE::DataAbstraction::OngoingCalculation.storage_method.should == :outputs
    end

    it "should establish whether inputs to be stored" do
      AMEE::DataAbstraction::OngoingCalculation.store_inputs?.should be_false
    end

    it "should establish whether outputs to be stored" do
      AMEE::DataAbstraction::OngoingCalculation.store_outputs?.should be_true
    end

    it "should establish whether metadata to be stored" do
      AMEE::DataAbstraction::OngoingCalculation.store_metadata?.should be_true
    end

    it "should start off dirty" do
      @ongoing_calculation.should be_dirty
    end

    it "should return array of terms for storing which includes only outputs and metadata" do
      @ongoing_calculation.stored_terms.should_not == @ongoing_calculation.terms
    end

    it "should return hash with only output and metadata terms" do
      hash = @ongoing_calculation.to_hash
      hash.is_a?(Hash).should be_true
      hash.should_not == @ongoing_calculation.to_hash(:full)
      hash.keys.map!(&:to_s).sort!.should == [:profile_item_uid, :profile_uid, 
                                              :calculation_type, :co2 ].map!(&:to_s).sort!
    end

    it "should save only output terms" do
      record = @ongoing_calculation.db_calculation
      # show that db record has all values
      record.to_hash.keys.map!(&:to_s).sort!.should == [:profile_item_uid, :profile_uid, :co2,
                                                        :usage, :country ].map!(&:to_s).sort!
      record.to_hash[:co2][:value].should == 1200
      record.to_hash[:usage][:value].should == 6000
      # show that db record contains only output terms after save
      @ongoing_calculation.save
      record = @ongoing_calculation.db_calculation
      record.to_hash.keys.map!(&:to_s).sort!.should == [:profile_item_uid, :profile_uid, :co2 ].map!(&:to_s).sort!
      record.to_hash[:co2][:value].should == 1200
      record.to_hash[:usage].should == nil
    end

  end

  describe "saving" do
    
    before :each do
      choose_mock
      yaml_load_mock(:outputs)
      @ongoing_calculation = AMEE::DataAbstraction::OngoingCalculation.find :first
    end
    
    it "should return true if successful" do
      @ongoing_calculation.save.should eql true
    end
    
    it "should return false if unsuccessful" do
      # Mock to make save fail
      flexmock(@ongoing_calculation.db_calculation).should_receive(:save!).and_raise(ActiveRecord::RecordNotSaved)
      # Saving should now return false, propogating errors from AR::Base
      @ongoing_calculation.save.should eql false
    end
    
  end

  describe "deleting calculation" do

    before(:all) do
      choose_mock
      delete_mock
      @ongoing_calculation = AMEE::DataAbstraction::OngoingCalculation.find :first
    end

    it "should remove record from db" do
      db_reference = @ongoing_calculation.db_calculation.id
      item_uid = @ongoing_calculation.send :profile_item_uid
      @ongoing_calculation.delete
      @ongoing_calculation.db_calculation.should be_nil
      AMEE::Db::Calculation.find_by_profile_item_uid(item_uid).should be_nil
      lambda{AMEE::Db::Calculation.find(db_reference)}.should raise_error
    end
  end

end