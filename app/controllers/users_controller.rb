class UsersController < ApplicationController
  before_filter :load_user, only: [:create]
  load_and_authorize_resource

  def index
    @users = @users.where("role is not null AND role <> ''") unless params[:all]
  end

  def new

  end

  def create
    if @user.save
      redirect_to @user, notice: t('users.create.success')
    else
      render 'new'
    end
  end

  def edit

  end

  def update
    if @user.update_attributes(user_params)
      redirect_to @user, notice: t('users.update.success')
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: t('users.destroy.success')
  end
  
  private
  def user_params
    params.require(:user).permit(
      :username,
      :federation_id,
      :role,
      :locale
    )
  end

  def load_user
    @user = User.new(user_params)
  end
end
