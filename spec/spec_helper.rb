require 'rubygems'
require 'rspec'
require 'yaml'
require 'logger'
require 'amee-data-persistence'

RSpec.configure do |config|
  config.mock_with :flexmock
end

class Rails
  def self.root
    File.dirname(__FILE__) + '/amee/fixtures'
  end
end

DB_CONFIG = YAML.load_file(File.dirname(__FILE__) + '/database.yml')
DB_MIGRATION = File.join(File.dirname(__FILE__), '..','lib','generators','persistence','templates','db','migrate')

ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
ActiveRecord::Base.establish_connection(DB_CONFIG)
ActiveRecord::Migrator.up(DB_MIGRATION)

def yaml_load_mock(method)
  flexmock(YAML) do |mock|
    mock.should_receive(:load_file).and_return('method' => method.to_s)
  end
end

def choose_mock
  selection_mock = flexmock "selection"
  selection_mock.should_receive(:selections).and_return({"country"=>"Argentina"})

  drill = AMEE::Data::DrillDown
  drill_mock = flexmock(drill)
  drill_mock.should_receive(:get).and_return(selection_mock)
end

def delete_mock
  item = AMEE::Profile::Item
  drill_mock = flexmock(item)
  drill_mock.should_receive(:delete).and_return(true)
end

def populate_db
  calculation_one = { :calculation_type => :electricity, :profile_item_uid => "J38DY57SK591",
                      :country => {:value =>'Argentina'}, 
                      :usage =>{:value => 6000},
                      :co2 =>{:value => 1200}}

  calculation_two = { :calculation_type => :electricity, :profile_item_uid => "CJ49FFU37DIW",
                      :country =>{:value => 'Argentina'}, 
                      :usage => {:value =>250},
                      :co2 =>{:value => 23000}}

  calculation_three = { :calculation_type => :electricity, :profile_item_uid => "K588DH47SMN5", :profile_uid => "H9KJ49FKIWO5",
                        :country => {:value =>'Argentina'},
                        :usage => {:value => 12345},
                        :co2 => {:value => 1.2}}

  [ calculation_one, calculation_two, calculation_three ].each do |attr|
    AMEE::Db::Calculation.new { |calc| calc.update_calculation! attr }
  end
end