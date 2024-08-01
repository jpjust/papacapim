class PostsController < ApplicationController

  before_action :authorize
  before_action :set_post, only: %i[ show update destroy ]

  # GET /posts
  def index
    page = params[:page].to_i || 0
    offset = ENV['POSTS_FEED_PAGELIMIT'] * page
    @posts = params[:feed].present? ? Post.where(user_id: current_user.following.map(&:id)) : Post.all
    @posts = @posts.limit(ENV['POSTS_FEED_PAGELIMIT']).offset(offset)

    render json: @posts
  end

  # GET /posts/1
  def show
    render json: @post
  end

  # POST /posts
  def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id

    if @post.save
      render json: @post, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    render(json: {}, status: 401) unless @post.user_id == current_user.id
    @post.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit([:post_id, :message])
    end
end
