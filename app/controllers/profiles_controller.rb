class ProfilesController < ApplicationController
  before_action :set_profile
  before_action :require_owner, only: [:edit, :update]

  layout 'weby_pages'

  helper_method :is_owner?

  respond_to :html

  def show
    @news = Journal::News.by_user(@profile.id).published.limit(3).order('journal_news.created_at desc')
  end

  def history
    @history = @profile.user_login_histories.order('created_at desc')
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      flash[:success] = t(profile_params.include?(:email) ? 'updated_account_with_email' : 'updated_account')
    end

    respond_with @profile, location: profile_url(@profile.login)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_profile
    @profile = User.find_by_login(params[:id])
  end

  def profile_params
    params.require(:user).permit(:login, :email, :password, :password_confirmation, :first_name, :last_name, :phone, :mobile, :locale_id)
  end

  # Responds if the current user is profile's owner.
  def is_owner?
    return false unless current_user
    return true if current_user.is_admin | (current_user == @profile)
  end

  # Test if is owner, else redirect to profile page with alert.
  def require_owner
    redirect_to({ action: :show, id: params[:id] }, flash: { error: t('no_permission_to_action') }) unless is_owner?
  end
end
