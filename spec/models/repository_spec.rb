require 'rails_helper'

describe Repository do
  it { expect(subject).to have_many(:page).with_foreign_key('repository_id') }

  it { expect(subject).to belong_to(:site) }

  it { expect(subject).to have_many(:pages_repositories).dependent(:destroy) }
  it { expect(subject).to have_many(:pages).through(:pages_repositories) }

  it { expect(subject).to have_many(:page_image).class_name('Page').dependent(:nullify) }
end
