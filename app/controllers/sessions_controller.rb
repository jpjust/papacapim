class SessionsController < ApplicationController

  before_action :authorize, only: %i[ index destroy ]

  # GET /sessions
  def index
    @sessions = current_user.sessions

    render json: @sessions, only: [:user_login, :ip]
  end

  # POST /sessions
  def create
    @user = User.find_by(login: params[:login].downcase) || User.new

    if @user.authenticate(params[:password])
      @session = Session.create!({
        user_id: @user.id,
        ip: request.remote_ip,
      })
      render json: @session, only: [:user_login, :token, :ip]
    else
      render json: {}, status: 401
    end
  end

  # DELETE /sessions/1
  def destroy
    current_session.destroy
  end

  private
    # Only allow a list of trusted parameters through.
    def session_params
      params.fetch(:session, {})
    end
end
