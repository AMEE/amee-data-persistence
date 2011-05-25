require 'amee-data-abstraction'
require 'amee-data-persistence'

::AMEE::DataAbstraction::OngoingCalculation.class_eval { include ::AMEE::DataAbstraction::PersistenceSupport }
