require 'rails_helper'

describe Repository do
  it { expect(subject).to have_many(:page).with_foreign_key('repository_id') }

  it { expect(subject).to belong_to(:site) }

  it { expect(subject).to have_many(:posts_repositories).dependent(:destroy) }
  it { expect(subject).to have_many(:pages).through(:posts_repositories) }

  it { expect(subject).to have_many(:page_image).class_name('Page').dependent(:nullify) }
end
