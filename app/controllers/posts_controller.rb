class PostsController < ApplicationController

  before_action :authorize
  before_action :set_post, only: %i[ show update destroy ]

  # TODO:
  # - list posts from user
  # - get a specific post
  # - list replies of a post

  # GET /posts
  def index
    page = params[:page].to_i || 0
    offset = ENV['POSTS_FEED_PAGELIMIT'] * page
    @posts = params[:feed].to_i == 1 ? Post.where(user_id: current_user.following.map(&:id)) : Post.all
    @posts = @posts.limit(ENV['POSTS_FEED_PAGELIMIT']).offset(offset)

    render json: @posts, :except => [:user_id]
  end

  # GET /posts/1
  def show
    render json: @post, :except => [:user_id]
  end

  # POST /posts
  def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id

    if @post.save
      render json: @post, :except => [:user_id], status: :created, location: @post
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
      render json: {}, status: 404 if @post.nil?
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit([:post_id, :message])
    end
end
