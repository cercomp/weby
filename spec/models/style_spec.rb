require 'spec_helper'

describe Style do
  it { expect(subject).to belong_to(:site) }
  it { expect(subject).to belong_to(:style) }

  it { expect(subject).to have_many(:styles).dependent(:restrict) }
  it { expect(subject).to have_many(:followers).through(:styles) }

  it { expect(subject).to validate_presence_of(:site) }
  it { expect(subject).to validate_presence_of(:name) }

  context 'when has style' do
    subject do
      site = create(:site, locales: [create(:locale)])
      style = create(:style, site: site)

      Style.new(style: style)
    end

    it { expect(subject).to_not validate_presence_of(:name) }
  end

  # TOOD: incompleto
end
