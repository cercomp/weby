require 'spec_helper'

describe User do

  it { expect(subject).to validate_presence_of(:email) } 
  it { expect(subject).to validate_presence_of(:login) } 
  it { expect(subject).to validate_presence_of(:first_name) } 
  it { expect(subject).to validate_presence_of(:last_name) } 
  it { expect(subject).to validate_presence_of(:password) } # TODO on: create

  context 'Email' do
    it 'should accept valid email addresses format' do
      expect(subject).to allow_value('user@domain.com').for(:email)
    end

    it 'should reject invalid email addresses format' do
      expect(subject).not_to allow_value('userdomain.com').for(:email)
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
  
  context 'Login' do
    it 'should accept valid login format' do
      expect(subject).to allow_value('login1').for(:login)
    end

    it 'should reject invalid login format' do
      expect(subject).not_to allow_value('log#in1').for(:login)
    end

    it 'should validate uniqueness of login' do
      user = create(:user)
      subject = build(:user, login: user.email)
      expect(subject).to validate_uniqueness_of(:login)
    end
  end

  context 'Password' do
    pending 'should confirm password' do
    end

    it 'should accept valid password format' do
      expect(subject).to allow_value('Admin1').for(:password).with_message(I18n.t('lower_upper_number_chars'))

    end

    pending 'should allow blank password on edit' do
    end

    it 'should reject invalid password format' do
      expect(subject).not_to allow_value('admin1').for(:password).with_message(I18n.t('lower_upper_number_chars'))
    end
  end

  context 'Roles' do
    it { expect(subject).to have_and_belong_to_many(:roles) }
  end

  context 'Locale' do
    it { expect(subject).to belong_to(:locale) }
  end

  context 'Notifications' do
    it { expect(subject).to have_many(:notifications).dependent(:nullify) }
  end

  context 'Pages' do
    it { expect(subject).to have_many(:pages).with_foreign_key(:author_id).dependent(:restrict) }
  end

  context 'Views' do
    it { expect(subject).to have_many(:views).dependent(:nullify) }
  end

  context 'Scopes' do
    it 'admin' do
      subject = create(:user)
      expect(User.admin).to include(subject)
    end

    it 'no_admin' do
      subject = create(:user, is_admin: false)
      expect(User.admin).not_to include(subject)
    end

    it 'login_or_name_like (LOGIN)' do
      subject = create(:user, login: "user", first_name: "John")
      user = create(:user, login: "login", first_name: "First Name")
      
      expect(User.login_or_name_like("us")).to include(subject)
      expect(User.login_or_name_like("login")).not_to include(subject)
      expect(User.login_or_name_like("First")).to include(user)
      expect(User.login_or_name_like("John")).not_to include(user)
    end

    it 'actives' do
      subject = create(:user)
      expect(User.actives).to include(subject)
    end

    pending 'by_site' do
    end
    pending 'actives' do
    end
    pending 'global_role' do
    end
    pending 'by_no_site' do
    end
  end

  context 'Self' do
    pending "should return the user full name when called fullname" do
    end

    pending "should return the user email with his name when called email_adrress_with_name" do
    end
    
    pending "should return the user's unread notifications as an array when called unread_notifications_array" do
    end
  end

end
