ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Las pruebas parten con las compañías abiertas a los consejeros (CompanyReveal), como estaban antes del
    # interruptor; las que prueban la compañía cerrada la cierran ellas mismas.
    setup { CompanyReveal.open! }

    # Add more helper methods to be used by all tests here...
  end
end
