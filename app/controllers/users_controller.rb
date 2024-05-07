class UsersController < ApplicationController
  before_action :authorize_user, only: [:edit, :update]

  def edit
    @user = User.find(params[:id])
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
        flash[:success] = "ユーザー情報を更新しました!"
        redirect_to @user
    else
        render :edit
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
