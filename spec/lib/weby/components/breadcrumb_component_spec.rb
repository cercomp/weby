require 'rails_helper'

describe BreadcrumbComponent do
  it { should have_setting :label }

  it { should have_i18n_setting :label }
end
