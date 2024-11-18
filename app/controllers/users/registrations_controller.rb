class Users::RegistrationsController < Devise::RegistrationsController
  before_action :set_breadcrumbs, only: [:edit]
  before_action :ensure_normal_user, only: [:edit, :update, :destroy]

  protected

  def after_sign_up_path_for(resource)
    root_path
  end

  def after_update_path_for(resource)
    user_path(resource)
  end

  def ensure_normal_user
    if current_user.email == "guest@example.com"
      redirect_to root_path, notice: "ゲストユーザーの情報は変更できません。"
    end
  end

  private

  def set_breadcrumbs
    add_breadcrumb @user.name, user_path(@user)
    add_breadcrumb "アカウント編集", edit_user_registration_path
  end
end
