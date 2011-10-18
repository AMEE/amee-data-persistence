# Copyright (C) 2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

require 'rubygems'
require 'active_record'
require 'quantify'
require 'amee-data-abstraction'

require 'amee/data_abstraction/calculation_collection'
require 'amee/data_abstraction/ongoing_calculation_persistence_support'
require 'amee/db/calculation'
require 'amee/db/term'
require 'amee/db/config'

::AMEE::DataAbstraction::OngoingCalculation.send :include,  ::AMEE::DataAbstraction::PersistenceSupport