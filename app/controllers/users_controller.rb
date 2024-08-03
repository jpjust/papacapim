class UsersController < ApplicationController

  before_action :authorize, except: %i[ create ]
  before_action :set_user, only: %i[ show ]

  # TODO:
  # - search users by name and login
  # - get user by login

  # GET /users
  def index
    page = params[:page].to_i || 0
    offset = ENV['USERLIST_PAGELIMIT'] * page
    @users = User.all.limit(ENV['USERLIST_PAGELIMIT']).offset(offset)

    render json: @users, except: [:password_digest]
  end

  # GET /users/login
  def show
    render json: @user, except: [:password_digest]
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, except: [:password_digest], status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/login
  def update
    @user = current_user
    if @user.update(user_params)
      render json: @user, except: [:password_digest]
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/login
  def destroy
    @user = current_user
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by(login: params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit([:login, :name, :password, :password_confirmation])
    end
end
