require 'spec_helper'

describe PagesRepository do
  it { expect(subject).to belong_to(:page) }
  it { expect(subject).to belong_to(:repository) }
end
