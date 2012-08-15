class UsersController < ApplicationController
  load_and_authorize_resource

  def index

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
    if @user.update_attributes(params[:user])
      redirect_to @user, notice: t('users.update.success')
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: t('users.destroy.success')
  end
end
