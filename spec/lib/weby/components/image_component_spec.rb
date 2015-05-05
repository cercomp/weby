require 'rails_helper'

describe ImageComponent do
  it { should have_setting :repository_id }
  it { should have_setting :size }
  it { should have_setting :height }
  it { should have_setting :width }
  it { should have_setting :target_type }
  it { should have_setting :target_id }
  it { should have_setting :url }
  it { should have_setting :new_tab }
  it { should have_setting :html_class }

  it { should validate_presence_of :repository_id }

  it { should allow_value('class').for(:html_class) }
  it { should_not allow_value('<body></bodyx>').for(:html_class) }

  describe '#new_tab' do
    it 'returns false when _new_tab is blank' do
      expect(subject.new_tab).to eq false
    end

    it 'returns false when _new_tab is diferent from 1' do
      allow(subject).to receive(:_new_tab).and_return 2

      expect(subject.new_tab).to eq false
    end

    it 'returns true when _new_tab is 1' do
      allow(subject).to receive(:_new_tab).and_return 1

      expect(subject.new_tab).to eq true
    end
  end
end
