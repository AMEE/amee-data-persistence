require 'rubygems'
require 'spec'
require 'rspec_spinner'
require 'yaml'
require 'logger'
gem 'amee-data-abstraction'
require 'amee-data-abstraction'

RAILS_ROOT = '.'

DB_CONFIG = YAML.load_file(File.dirname(__FILE__) + '/database.yml')
DB_MIGRATION = File.join(File.dirname(__FILE__), '..','generators','persistence','templates','db','migrate')

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'amee-data-persistence'
require 'amee/data_abstraction/persistence_support'

ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
AMEE::DataAbstraction::OngoingCalculation.class_eval { include AMEE::DataAbstraction::PersistenceSupport }

ActiveRecord::Base.establish_connection(DB_CONFIG)
ActiveRecord::Migrator.up(DB_MIGRATION)

Spec::Runner.configure do |config|
  config.mock_with :flexmock
end

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

def initialize_calculation_set
  eval "Calculations = AMEE::DataAbstraction::CalculationSet.new {
      calculation{
        name 'Electricity'
        label :electricity
        path '/business/energy/electricity/grid'
        drill {
          label :country
          path 'country'
          fixed 'Argentina'
        }
        profile {
          label :usage
          name 'Electricity Used'
          path 'energyPerTime'
        }
        output {
          label :co2
          name 'Carbon Dioxide'
          path :default
        }
      }
    }"
end


# Stub activerecord for rails tests
# Taken from http://muness.blogspot.com/2006/12/unit-testing-rails-activerecord-classes.html
#class ActiveRecordUnitTestHelper
# attr_accessor :klass
#
# def initialize klass
#   self.klass = klass
#   self
# end
#
# def where attributes
#   klass.stubs(:columns).returns(columns(attributes))
#   instance = klass.new(attributes)
#   instance.id = attributes[:id] if attributes[:id] #the id attributes works differently on active record classes
#   instance
# end
#
#protected
# def columns attributes
#   attributes.keys.collect{|attribute| column attribute.to_s, attributes[attribute]}
# end
#
# def column column_name, value
#   ActiveRecord::ConnectionAdapters::Column.new(column_name, nil, ActiveRecordUnitTestHelper.active_record_type(value.class), false)
# end
#
# def self.active_record_type klass
#   return case klass.name
#     when "Fixnum"         then "integer"
#     when "Float"          then "float"
#     when "Time"           then "time"
#     when "Date"           then "date"
#     when "String"         then "string"
#     when "Object"         then "boolean"
#   end
# end
#end
#
#def disconnected klass
# ActiveRecordUnitTestHelper.new(klass)
#ßend
