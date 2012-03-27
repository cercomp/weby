require 'spec_helper'

describe Style do


  it { should validate_presence_of(:name) }
  it { should allow_value("Nome Estilo").for(:name) }

  it "Should belong to an owner" do
    subject.should belong_to(:owner)
    subject.should validate_numericality_of(:owner_id) 
  end
end


