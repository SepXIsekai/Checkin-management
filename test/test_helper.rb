# test/test_helper.rb
# require "simplecov"
require "simplecov_json_formatter"

# HTML for local viewing, JSON for SonarQube
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
]

SimpleCov.command_name "Minitest"
SimpleCov.start "rails" do
  enable_coverage :branch

  # Skip jobs และ mailers
  add_filter "/app/jobs/"
  add_filter "/app/mailers/"
  add_filter "/app/channels/"

  # Skip อื่นๆ ที่ไม่ต้องการ test
  add_filter "/config/"
  add_filter "/db/"
  add_filter "/vendor/"
  add_filter "/test/"
end
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)
    parallelize_setup do |worker|
      SimpleCov.command_name("#{SimpleCov.command_name}-#{worker}")
    end

    parallelize_teardown do |worker|
      SimpleCov.result
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
