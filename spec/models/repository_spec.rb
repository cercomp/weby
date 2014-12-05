require 'rails_helper'

describe Repository do
  skip { expect(subject).to have_many(:posts).through(:posts_repositories) }

  it { expect(subject).to belong_to(:site) }

  it { expect(subject).to have_many(:posts_repositories).dependent(:destroy) }
end
