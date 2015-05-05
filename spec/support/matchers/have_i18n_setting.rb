require 'rspec/expectations'

RSpec::Matchers.define :have_i18n_setting do |expected|
  match do |actual|
    method = expected.to_s + '_i18n'

    actual.respond_to? method.to_sym
  end

  failure_message do |actual|
    "expected #{actual.class} to have a i18n setting called #{expected}."
  end

  description do
    "define a i18n setting called #{expected}."
  end
end
