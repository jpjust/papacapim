class UsersController < ApplicationController

  before_action :authorize, except: %i[ create ]
  before_action :set_user, only: %i[ show ]

  # GET /users
  def index
    # Pagination
    page = params[:page].to_i || 0
    offset = ENV['USERLIST_PAGELIMIT'].to_i * page
    @users = User.all

    # Filters (for user search)
    search_query = params[:search].to_s.strip.gsub(/\s+/, '*,') + '*'
    @users = @users.where('MATCH(name) AGAINST(? IN BOOLEAN MODE)', search_query) if params[:search].present?

    render json: @users.limit(ENV['USERLIST_PAGELIMIT'].to_i).offset(offset), only: [:login, :name, :profile_image]
  end

  # GET /users/login
  def show
    render json: @user, only: [:login, :name, :profile_image]
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, only: [:login, :name, :created_at], status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/login
  def update
    @user = current_user
    if @user.update(user_params)
      # Limpa as sessões de alterar a senha
      # Session.where(user_id: @user.id).destroy_all if @user.password.present?

      # Salva a imagem de perfil
      if params[:image_data].present?
        max_file_size = 5.megabytes
        max_base64_size = ((max_file_size * 4.0) / 3).ceil

        begin
          image_data = Base64.strict_decode64(params[:image_data])

          if image_data.bytesize <= max_base64_size
            tmp_file = File.join(Rails.root, 'tmp', "#{@user.login}.png")
            dest_file = File.join(Rails.root, 'public', 'image', 'profile', "#{@user.login}.webp")
            File.binwrite(tmp_file, image_data)
            system('/usr/bin/convert', tmp_file, dest_file)
            File.delete(tmp_file)
          end
        rescue ArgumentError => e
          puts e.message
        end
      end

      render json: @user, only: [:login, :name]
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
