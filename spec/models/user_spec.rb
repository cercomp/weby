require 'spec_helper'

describe User do

  it { expect(subject).to validate_presence_of(:email) } 
  it { expect(subject).to validate_presence_of(:login) } 
  it { expect(subject).to validate_presence_of(:first_name) } 
  it { expect(subject).to validate_presence_of(:last_name) } 

  context 'email' do
    it 'should accept valid email addresses format' do
      subject = build(:user) 
      expect(subject.email).to match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
    end

    it 'should reject invalid email addresses format' do
      subject = build(:user, email: 'askdjasldasdjl.com')
      expect(subject.email).not_to match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
    end

    it 'should validate uniqueness of email addresses' do
      user = create(:user)
      subject = build(:user, email: user.email)
      expect(subject).to validate_uniqueness_of(:email)
    end

    it 'should reject email addresses identical up to case' do
      user = create(:user)
      subject = build(:user, email: user.email.upcase)
      expect(subject).to validate_uniqueness_of(:email)
    end

    it 'should change email into downcase before saving' do
      subject= build(:user, email:"EMAIL@email.com")
      subject.save
      expect(subject.email).to eq(subject.email.downcase)
    end
  end
  
  context 'login' do
    it 'should accept valid login format' do
      subject = build(:user)
      expect(subject.login).to match(/^[a-z\d_\-\.@]+$/i)
    end

    it 'should reject invalid login format' do
      subject = build(:user, login: 'log#in')
      expect(subject.login).not_to match(/^[a-z\d_\-\.@]+$/i)                            
    end

    it 'should validate uniqueness of login' do
      user = create(:user)
      subject = build(:user, login: user.email)
      expect(subject).to validate_uniqueness_of(:login)
    end
  end

  context 'password' do
    pending 'should confirm password' do
    end

    it 'should accept valid password format' do
      subject = build(:user)
      expect(subject.password).to match(/(?=.*\d+)(?=.*[A-Z]+)(?=.*[a-z]+)^.{4,}$/)
    end

    it 'should reject invalid password format' do
      subject = build(:user, password: 'a1234')
      expect(subject.password).not_to match(/(?=.*\d+)(?=.*[A-Z]+)(?=.*[a-z]+)^.{4,}$/)
    end
  end

  context 'roles' do
  end

  context 'locale' do
  end

end
