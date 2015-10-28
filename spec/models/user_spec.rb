require 'rails_helper'

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
      user = create(:user, password_salt: 'salt', encrypted_password: 'salt')
      subject = build(:user, email: user.email)
      expect(subject).to validate_uniqueness_of(:email)
    end

    it 'should reject email addresses identical up to case' do
      user = create(:user, password_salt: 'salt', encrypted_password: 'salt')
      subject = build(:user, email: user.email.upcase)
      expect(subject).to validate_uniqueness_of(:email)
    end

    it 'should change email into downcase before saving' do
      subject = build(:user, email: 'EMAIL@email.com', password_salt: 'salt', encrypted_password: 'salt')
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
      user = create(:user, password_salt: 'salt', encrypted_password: 'salt')
      subject = build(:user, login: user.email)
      expect(subject).to validate_uniqueness_of(:login)
    end
  end

  context 'Password' do
    describe 'should not allow when password is not present' do
      before do
        @user = create(:user, login: 'user', first_name: 'John', password_salt: '', encrypted_password: '')
      end

      it { should_not be_valid }
    end

    describe 'should not allow password mismatch' do
      before { @user = create(:user, password_salt: '', encrypted_password: 'wrong_password') }
      it { should_not be_valid }
    end

    describe "when password doesn't match confirmation" do
      before { @user = create(:user, password_salt: 'mismatch', encrypted_password: 'mismatch') }
      it { should_not be_valid }
    end

    it 'should accept valid password format' do
      expect(subject).to allow_value('Admin1').for(:password).with_message(I18n.t('lower_upper_number_chars'))
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

  context 'LoginHistories' do
    it { expect(subject).to have_many(:user_login_histories).dependent(:destroy) }
  end

  context 'Notifications' do
    it { expect(subject).to have_many(:notifications).dependent(:nullify) }
  end

  context 'Pages' do
    skip { expect(subject).to have_many(:pages).with_foreign_key(:user_id).dependent(:restrict_with_error) }
  end

  context 'Views' do
    it { expect(subject).to have_many(:views).dependent(:nullify) }
  end

  context 'Scopes' do
    it 'admin' do
      subject = create(:user, password_salt: 'salt', encrypted_password: 'salt')
      expect(User.admin).to include(subject)
    end

    it 'no_admin' do
      subject = create(:user, is_admin: false, password_salt: 'salt', encrypted_password: 'salt')
      expect(User.admin).not_to include(subject)
    end

    it 'login_or_name_like (LOGIN)' do
      subject = create(:user, login: 'user', first_name: 'John', password_salt: 'salt', encrypted_password: 'salt')
      user = create(:user, login: 'login', first_name: 'First Name', password_salt: 'salt', encrypted_password: 'salt')

      expect(User.login_or_name_like('us')).to include(subject)
      expect(User.login_or_name_like('login')).not_to include(subject)
      expect(User.login_or_name_like('First')).to include(user)
      expect(User.login_or_name_like('John')).not_to include(user)
    end

    it 'actives' do
      subject = create(:user, password_salt: 'salt', encrypted_password: 'salt')
      expect(User.actives).to include(subject)
    end

    skip 'by_site' do
      subject = create(:user, login: 'user', first_name: 'John', password_salt: 'salt', encrypted_password: 'salt')
      site = build(:site)
      create(:role, site_id: site.id)
      # role_user = create(:role_user, role_id: role.id, user_id: subject.id)

      expect(User.by_ste(site.id)).to include(subject)
    end

    skip 'global_role' do
    end

    skip 'by_no_site' do
    end
  end

  describe '#to_s' do
    it 'returns name or login' do
      name_or_login = double(:name_or_login)

      allow(subject).to receive(:name_or_login).and_return(name_or_login)

      expect(subject.to_s).to eq name_or_login
    end
  end

  describe '#name_or_login' do
    it 'returns full name when has first name' do
      allow(subject).to receive(:first_name).and_return(true)
      allow(subject).to receive(:fullname).and_return('Full Name')

      expect(subject.name_or_login).to eq('Full Name')
    end

    it "returns login when hasn't first name" do
      allow(subject).to receive(:first_name).and_return(false)
      allow(subject).to receive(:login).and_return('Login')

      expect(subject.name_or_login).to eq('Login')
    end
  end

  describe '#email_address_with_name' do
    it 'returns the e-mail with full name when has first name' do
      subject.first_name = 'First'
      subject.last_name = 'Last'
      subject.email = 'E-mail'

      expect(subject.email_address_with_name).to eq('First Last <E-mail>')
    end

    it "returns the login with email when hasn't first name" do
      subject.login = 'Login'
      subject.email = 'E-mail'

      expect(subject.email_address_with_name).to eq('Login <E-mail>')
    end
  end

  describe '#unread_notifications_array' do
    it 'returns an array with ids from noticifications' do
      subject.unread_notifications = '1,2,3,4,5,6'

      expect(subject.unread_notifications_array).to eq([1, 2, 3, 4, 5, 6])
    end
  end

  describe '#append_unread_notification' do
    it "doesn't append without noticification" do
      expect(subject.append_unread_notification(nil)).to be_nil
    end

    it 'appends a notification' do
      notification = double(:notification, id: 1)

      allow(subject).to receive(:unread_notifications_array).and_return([2, 3])
      allow(subject).to receive(:update_attribute).with(:unread_notifications, '2,3,1')

      subject.append_unread_notification(notification)
    end
  end

  describe '#remove_unread_notification' do
    it 'removes specific unread notification' do
      notification = double(:notification, id: 1)

      allow(subject).to receive(:unread_notifications_array).and_return([1, 2, 3])
      allow(subject).to receive(:update_attribute).with(:unread_notifications, '2,3')

      subject.remove_unread_notification(notification)
    end

    it 'removes all unread notification' do
      allow(subject).to receive(:unread_notifications_array).and_return([1, 2, 3])
      allow(subject).to receive(:update_attribute).with(:unread_notifications, '')

      subject.remove_unread_notification
    end
  end

  describe '#is_local_admin?' do
    it 'returns user if it is local admin' do
      subject.id = 2
      allow(User).to receive(:local_admin).with(1).and_return(User)
      allow(User).to receive(:find_by).with(id: 2).and_return(subject)

      expect(subject.is_local_admin?(1)).to eq(subject)
    end
  end

  describe '#has_read?' do
    it 'returns true if the notification has been read' do

      notification = double(:notification, id: 3)

      expect(subject.has_read?(notification)).to eq(true)
    end

    it "returns false if the notification hasn't been read" do
      notification1 = double(:notification, id: 2)
      allow(subject).to receive(:unread_notifications_array).and_return([1, 2])

      expect(subject.has_read?(notification1)).to eq(false)
    end
  end

  describe '#has_role_in?' do
    before do
      @site = double(:site)
    end

    it 'returns true if user is admin' do
      allow(subject).to receive(:is_admin?).and_return(true)

      expect(subject.has_role_in?(@site)).to eq(true)
    end

    it 'returns true if user sites inclue site' do
      allow(subject).to receive(:is_admin?).and_return(false)
      allow(subject).to receive(:sites).and_return([:site1, @site])

      expect(subject.has_role_in?(@site)).to eq(true)
    end

    it 'returns true if has a global role' do
      allow(subject).to receive(:is_admin?).and_return(false)
      allow(subject).to receive(:sites).and_return([:site1])
      allow(subject).to receive(:global_roles).and_return([1])

      expect(subject.has_role_in?(@site)).to eq(true)
    end

    it "returns false when user isn't admin, sites doesn't include site and hasn't global role" do
      allow(subject).to receive(:is_admin?).and_return(false)
      allow(subject).to receive(:sites).and_return([:site1])
      allow(subject).to receive(:global_roles).and_return([])

      expect(subject.has_role_in?(@site)).to eq(false)
    end
  end

  describe '#sites' do
    it 'returns sites thar user has role' do
      role1 = double(:role1, site_id: 1)
      role2 = double(:role2, site_id: 2)
      role3 = double(:role3, site_id: 1)

      allow(subject).to receive(:roles).and_return([role1, role2, role3])
      allow(Site).to receive(:where).with(id: [1, 2])

      subject.sites
    end
  end
end
