## amee-data-persistence

The amee-data-persistence gem provides database support for use in conjunction
with the amee-data-abstraction gem.

Licensed under the BSD 3-Clause license (See LICENSE.txt for details)

Authors: James Hetherington, James Smith, Andrew Berkeley, George Palmer

Copyright: Copyright (c) 2011 AMEE UK Ltd

Homepage: http://github.com/AMEE/amee-data-persistence

Documentation: http://rubydoc.info/gems/amee-data-persistence

## INSTALLATION

 gem install amee-data-persistence
 
## REQUIREMENTS

 * ruby 1.8.7
 * rubygems >= 1.5

 All gem requirements should be installed as part of the rubygems installation process 
 above, but are listed here for completeness.

 * amee-data-abstraction ~> 1.0.0
 
## USAGE

The library repesents calculations as
database records using two classes (_AMEE::Db::Calculation_ and
_AMEE::Db::Term_) both of which inherit _ActiveRecord::Base_.

The library also defines the _AMEE::DataAbstraction::PersistenceSupport_
module which is mixed into the _AMEE::DataAbstraction::OngoingCalculation_
class by default when the library is required. The module provides a number of
class and instance methods which provide an interface between the
_AMEE::DataAbstraction::OngoingCalculation_ class (and its instances) and
the database. It is via these methods that the persistence functionality
provided by the _AMEE::Db_ classes is principally used.

The level of data storage can be configured to three distinct levels, representing
the range of calculation terms which are persisted: all; outputs and metadata only;
and metadata only.

The global persistence storage level and migrations for the database tables
(under /db/migrate) can be generated using the command line generator command:

  $ rails generate persistence <storage_level>

where `<storage_level>` can be either 'everything', 'outputs' or 'metadata', e.g.,

  $ rails generate persistence everything


### Example usage

    my_calculation = OngoingCalculation.find(:first)

                                   #=> <AMEE::DataAbstraction::OngoingCalculation ... >

    my_calculation = OngoingCalculation.find(28)

                                   #=> <AMEE::DataAbstraction::OngoingCalculation ... >

    my_calculation = OngoingCalculation.find(:all)

                                   #=> <AMEE::DataAbstraction::CalculationCollection ... >

    my_calculation = OngoingCalculation.where('calculation_type = ?', 'electricity')

                                   #=> <AMEE::DataAbstraction::CalculationCollection ... >

    my_calculation.id              #= 28

    my_calculation.db_calculation  #=> <AMEE::Db::Calculation ... >

    my_calculation.to_hash         #=> { :profile_uid => "EYR758EY36WY",
                                         :profile_item_uid => "W83URT48DY3W",
                                         :type => { :value => 'car' },
                                         :distance => { :value => 1600,
                                                        :unit => <Quantify::Unit::SI> },
                                         :co2 => { :value => 234.1,
                                                   :unit => <Quantify::Unit::NonSI> }}

    my_calculation.save            #=> true

    my_calculation.delete          #=> nil

In order to use the persistence library, prototype calculations must be held within
instances of the AMEE::DataAbstraction::CalculationSet class