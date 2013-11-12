require 'spec_helper'

describe SitesStyle do
  it { expect(subject).to belong_to(:site) }
  it { expect(subject).to belong_to(:site) }
  it { expect(subject).to belong_to(:style) }

  it { expect(subject).to validate_presence_of(:site) }
  it { expect(subject).to validate_presence_of(:style) }

  it 'should require case sensitive unique value for style_id scoped to site_id' do
    locale = create(:locale)
    site_1 = create(:site, locales: [locale])
    site_2 = create(:site, locales: [locale])
    style = create(:style, owner: site_1)
    create(:sites_style, site: site_2, style: style)

    expect(subject).to validate_uniqueness_of(:style_id).scoped_to(:site_id)
  end

  it 'should publish is default false' do
    subject = SitesStyle.new

    expect(subject.publish).to eq true
  end
end
