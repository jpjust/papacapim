class UsersController < ApplicationController

  before_action :authorize, except: %i[ create ]
  before_action :set_user, only: %i[ show ]

  # GET /users
  def index
    # Pagination
    page = params[:page].to_i || 0
    offset = ENV['USERLIST_PAGELIMIT'] * page
    @users = User.all

    # Filters (for user search)
    search_query = "%#{params[:search].gsub(/\s+/, '%')}%"
    @users = @users.where('login LIKE ? OR name LIKE ?', search_query, search_query) if params[:search].present?

    render json: @users.limit(ENV['USERLIST_PAGELIMIT']).offset(offset), except: [:id, :password_digest]
  end

  # GET /users/login
  def show
    render json: @user, except: [:id, :password_digest]
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, except: [:id, :password_digest], status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/login
  def update
    @user = current_user
    if @user.update(user_params)
      Session.where(user_id: @user.id).destroy_all if @user.password.present?
      render json: @user, except: [:id, :password_digest]
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
      render json: {}, status: 404 if @user.nil?
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit([:login, :name, :password, :password_confirmation])
    end
end
