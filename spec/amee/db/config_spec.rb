require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe AMEE::Db::Config do
  
  describe 'with everything stored' do
    
    before :all do
      flexmock(YAML) do |mock|
        mock.should_receive(:load_file).and_return('method' => 'everything').once
      end
      @config = AMEE::Db::BaseConfig.new
    end
      
    it 'should load method from file' do
      @config.storage_method.should be(:everything)
    end

    it 'should correctly answer query methods' do
      @config.store_metadata?.should be_true
      @config.store_outputs?.should be_true
      @config.store_everything?.should be_true
    end
    
  end

  describe 'with metadata stored' do
    
    before :all do
      flexmock(YAML) do |mock|
        mock.should_receive(:load_file).and_return('method' => 'metadata').once
      end
      @config = AMEE::Db::BaseConfig.new
    end
      
    it 'should correctly answer query methods' do
      @config.store_metadata?.should be_true
      @config.store_outputs?.should be_false
      @config.store_everything?.should be_false
    end
    
  end

  describe 'with outputs stored' do
    
    before :all do
      flexmock(YAML) do |mock|
        mock.should_receive(:load_file).and_return('method' => 'outputs').once
      end
      @config = AMEE::Db::BaseConfig.new
    end
      
    it 'should correctly answer query methods' do
      @config.store_metadata?.should be_true
      @config.store_outputs?.should be_true
      @config.store_everything?.should be_false
    end
    
  end

  describe 'with invalid method' do
    
    before :all do
      flexmock(YAML) do |mock|
        mock.should_receive(:load_file).and_return('method' => 'invalid').once
      end
    end
      
    it 'should raise an exception on load' do
      lambda {
        AMEE::Db::BaseConfig.new
      }.should raise_error
    end
    
  end

  describe 'with invalid data in file' do
    
    before :all do
      flexmock(YAML) do |mock|
        mock.should_receive(:load_file).and_return({}).once
      end
    end
      
    it 'should raise an exception on load' do
      lambda {
        AMEE::Db::BaseConfig.new
      }.should raise_error
    end
    
  end

end