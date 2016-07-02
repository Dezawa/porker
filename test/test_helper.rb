ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  # Add more helper methods to be used by all tests here...
  def self.must(name,&block)
    test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
    defined = instanth_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block
      define_method(test_name,block)
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end

  end


end
