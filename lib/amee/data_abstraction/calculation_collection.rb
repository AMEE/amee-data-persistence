# Copyright (C) 2011 AMEE UK Ltd. - http://www.amee.com
# Released as Open Source Software under the BSD 3-Clause license. See LICENSE.txt for details.

# :title: Class: AMEE::DataAbstraction::CalculationCollection

module AMEE
  module DataAbstraction

    # Class for containing a collection of instances of the class
    # <i>OngoingCalculation</i>. This class is used to return mutliple
    # ongoing calculation objects using the <i>OngoingCalculation.find</i>
    # class method.
    #
    # This class is extended by the amee-reporting gem to provide analytical
    # methods which can be applied across collections of caluclations (e.g.
    # averages and summations of terms, sorting, etc.)
    #
    class CalculationCollection < Array

    end
  end
end
