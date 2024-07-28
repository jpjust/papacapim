class UsersController < ApplicationController

  before_action :authorize, except: %i[ create ]
  before_action :set_user, only: %i[ show ]

  # GET /users
  def index
    @users = User.all

    render json: @users, except: [:password_digest]
  end

  # GET /users/1
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

  # PATCH/PUT /users/1
  def update
    @user = current_user
    if @user.update(user_params)
      render json: @user, except: [:password_digest]
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user = current_user
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit([:login, :name, :password, :password_confirmation])
    end
end
