require 'spec_helper'

describe User do

  it { expect(subject).to validate_presence_of(:email) } 
  it { expect(subject).to validate_presence_of(:login) } 
  it { expect(subject).to validate_presence_of(:first_name) } 
  it { expect(subject).to validate_presence_of(:last_name) } 

  context 'email' do
    pending 'should accept valid email addresses format' do
    end

    pending 'should reject invalid email addresses format' do
    end

    it 'should validate uniqueness of email addresses' do
      user = create(:user)
      subject = build(:user, email: user.email)
      expect(subject).to validate_uniqueness_of(:email)
    end

    pending 'should reject email addresses identical up to case' do
    end

    pending 'should change email into downcase before a save' do
    end
  end
  
  context 'login' do
    pending 'should accept valid login format' do
    end

    pending 'should reject invalid login format' do
    end

    pending 'should validate uniqueness of login' do
    end

  end

  context 'password' do
    pending 'should confirm password' do
    end

    pending 'should accept valid password format ' do
    end

    pending 'should reject invalid password format' do
    end

  end

end
