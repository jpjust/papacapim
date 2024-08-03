class FollowersController < ApplicationController

  before_action :authorize
  before_action :set_user, only: %i[ index create ]
  before_action :set_follower, only: %i[ destroy ]

  # GET /users/:user_id/followers
  def index
    render json: @user.followers, :except => [:password_digest]
  end

  # POST /users/:user_id/followers
  def create
    @follower = Follower.new(followed_id: @user.id, follower_id: current_user.id)

    if @follower.save
      render json: @follower, :except => [:password_digest], status: :created, location: user_follower_url(@user.id, @follower.id)
    else
      render json: @follower.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/:user_id/followers/1
  def destroy
    unless @follower.try(:follower_id) == current_user.id 
      render json: {}, status: 401
      return
    end

    @follower.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_follower
      set_user
      @follower = Follower.find_by(follower_id: current_user.id, followed_id: @user.id)
    end

    def set_user
      @user = User.find_by(login: params[:user_id])
    end

    # Only allow a list of trusted parameters through.
    def follower_params
      params.fetch(:follower, {})
    end
end
