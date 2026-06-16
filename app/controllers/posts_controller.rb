class PostsController < ApplicationController

  before_action :authorize
  before_action :set_post, only: %i[ show update destroy ]

  # GET /posts
  def index
    page = params[:page].to_i || 0
    offset = ENV['POSTS_FEED_PAGELIMIT'].to_i * page
    @posts = Post.order(created_at: :desc)

    if params[:user_id].present?
      @posts = @posts.where(user_id: User.find_by(login: params[:user_id]))
    elsif params[:feed].to_i == 1
      @posts = Post.where(user_id: current_user.following.map(&:followed_id))
    elsif params[:search].present?
      search_query = params[:search].to_s.strip.gsub(/\s+/, '*,') + '*'
      @posts = @posts.where('MATCH(message) AGAINST(? IN BOOLEAN MODE)', search_query) 
    end

    render json: @posts.includes([:user, :likes])
                       .limit(ENV['POSTS_FEED_PAGELIMIT'].to_i)
                       .offset(offset)
                       .each{ |p| p.you_liked = p.likes.where(user_id: @current_user.id).count > 0 },
           only: [:id, :message, :created_at, :post_id, :likes_number, :replies_number, :you_liked],
           include: [
             user: {only: [:login, :name, :profile_image]}
           ]
  end

  # GET /posts/1
  def show
    render json: @post,
           only: [:id, :message, :created_at, :post_id, :likes_number, :replies_number, :you_liked],
           include: [
             user: {only: [:login, :name, :profile_image]}
           ]
  end

  # POST /posts
  def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id

    if @post.save
      render json: @post, only: [:id, :message, :created_at, :post_id], status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    render json: {}, status: 401 unless @post.user_id == current_user.id
    @post.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
      render json: {}, status: 404 if @post.nil?
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit([:message, :post_id])
    end
end
