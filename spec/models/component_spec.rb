require 'spec_helper'

describe Component do
  it { expect(subject).to belong_to(:site) }

  it { expect(subject).to validate_presence_of(:alias) }

  it 'should publish default is true' do
    expect(subject.publish).to eql true
  end

  context 'before_save' do
    before do
      component = Component.new(publish: false)
      component.save
    end

    it { should_not be_valid }
  end

  pending 'after_destroy' do
    before :each do
      @component1 = Component.new(place_holder: 'top', position: 1)
      @component1.save
      @component2 = Component.new(place_holder: 'top', position: 2)
      @component2.save
    end

    it "changes place_holder of children" do
      expect {
        delete :destroy, id: @component1
      }.to change(@component2, :position).by(-1)
    end
  end
end
