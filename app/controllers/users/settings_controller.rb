class Users::SettingsController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def update_account
    if current_user.update_with_password(account_params)
      bypass_sign_in(current_user)
      redirect_to users_settings_path(tab: "account"), notice: "アカウント情報を更新しました"
    else
      params[:tab] = "account"
      params[:edit] = "account"
      render :show, status: :unprocessable_entity
    end
  end

  def update_profile
    if current_user.update(profile_params)
      redirect_to users_settings_path(tab: "profile"), notice: "プロフィールを更新しました"
    else
      params[:tab] = "profile"
      params[:edit] = "profile"
      render :show, status: :unprocessable_entity
    end
  end
  
  private
  
  def account_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password)
  end

  def profile_params
    params.require(:user).permit(:username, :avatar)
  end
end