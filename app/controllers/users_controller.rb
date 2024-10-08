class UsersController < ApplicationController
  before_action :authorize_user, only: [:edit, :update]

  def edit
    if current_user.email == "guest@example.com"
      redirect_to root_path, notice: "ゲストユーザーの情報は変更できません。"
    else
      @user = User.find(params[:id])
      add_breadcrumb @user.name, user_path(@user)
      add_breadcrumb "プロフィール編集"
    end
  end

  def show
    @user = User.includes(shops: { image_attachment: :blob }).find(params[:id])
    @liked_shops = Shop.joins(:likes).includes(image_attachment: :blob).where(likes: { user_id: @user.id })
    add_breadcrumb @user.name
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to @user, notice: "ユーザー情報を更新しました!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :image)
  end

  def authorize_user
    @user = User.find(params[:id])
    redirect_to root_path unless @user == current_user
  end
end
