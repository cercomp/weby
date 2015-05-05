require 'rspec/expectations'

RSpec::Matchers.define :have_setting do |expected|
  match do |actual|
    getter = actual.respond_to? expected

    setter_method = expected.to_s + '='

    setter = actual.respond_to? setter_method.to_sym

    getter && setter
  end

  failure_message do |actual|
    "expected #{actual.class} to have a setting called #{expected}."
  end

  description do
    "define a setting called #{expected}."
  end
end
