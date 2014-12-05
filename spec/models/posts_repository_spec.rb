require 'rails_helper'

describe PostsRepository do
  it { expect(subject).to belong_to(:post) }
  it { expect(subject).to belong_to(:repository) }
end
