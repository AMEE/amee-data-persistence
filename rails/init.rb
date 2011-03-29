if defined?(AMEE::DataAbstraction::OngoingCalculation)
  AMEE::DataAbstraction::OngoingCalculation.class_eval { include AMEE::DataAbstraction::PersistenceSupport }
end
