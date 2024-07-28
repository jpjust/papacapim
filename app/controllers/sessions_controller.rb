class SessionsController < ApplicationController
  before_action :authorize, only: %i[ index destroy ]

  # GET /sessions
  def index
    @sessions = current_user.sessions

    render json: @sessions
  end

  # POST /sessions
  def create
    @user = User.find_by(login: params[:login].downcase) || User.new

    if @user.authenticate(params[:password])
      @session = Session.create!({
        user_id: @user.id,
        ip: request.remote_ip,
      })
      render json: @session
    else
      render json: {}, status: 401
    end
  end

  # DELETE /sessions/1
  def destroy
    @session.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = Session.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def session_params
      params.fetch(:session, {})
    end
end
